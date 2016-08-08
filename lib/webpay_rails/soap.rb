module WebpayRails
  class Soap
    extend Savon::Model

    def initialize(args)
      @private_key = OpenSSL::PKey::RSA.new(args[:private_key])
      @public_cert = OpenSSL::X509::Certificate.new(args[:public_cert])
      @environment = args[:environment]

      self.class.client(wsdl: wsdl_path)
    end

    def init_transaction(commerce_code, amount, buy_order, session_id, return_url, final_url)
      request = client.build_request(:init_transaction, message: {
        wsInitTransactionInput: {
          wSTransactionType: 'TR_NORMAL_WS',
          buyOrder: buy_order,
          sessionId: session_id,
          returnURL: return_url,
          finalURL: final_url,
          transactionDetails: {
            amount: amount,
            commerceCode: commerce_code,
            buyOrder: buy_order
          }
        }
      })

      call(request, :init_transaction)
    end

    def get_transaction_result(token)
      request = client.build_request(:get_transaction_result, message: {
        tokenInput: token
      })

      call(request, :get_transaction_result)
    end

    def acknowledge_transaction(token)
      request = client.build_request(:acknowledge_transaction, message: {
        tokenInput: token
      })

      call(request, :acknowledge_transaction)
    end

  private

    def call(request, operation)
      signed_document = sign_xml(request)

      client.call(operation) do
        xml signed_document.to_xml(save_with: 0)
      end
    end

    def sign_xml(input_xml)
      document = Nokogiri::XML(input_xml.body)
      envelope = document.at_xpath('//env:Envelope')
      envelope.prepend_child('<env:Header><wsse:Security xmlns:wsse=\'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\' wsse:mustUnderstand=\'1\'/></env:Header>')
      xml = document.to_s

      signer = Signer.new(xml)

      signer.cert = @public_cert
      signer.private_key = @private_key

      signer.document.xpath('//soapenv:Body', { soapenv: 'http://schemas.xmlsoap.org/soap/envelope/' }).each do |node|
        signer.digest!(node)
      end

      signer.sign!(issuer_serial: true)
      signed_xml = signer.to_xml

      document = Nokogiri::XML(signed_xml)
      x509data = document.at_xpath('//*[local-name()=\'X509Data\']')
      new_data = x509data.clone()
      new_data.set_attribute('xmlns:ds', 'http://www.w3.org/2000/09/xmldsig#')

      n = Nokogiri::XML::Node.new('wsse:SecurityTokenReference', document)
      n.add_child(new_data)
      x509data.add_next_sibling(n)

      document
    end

    def wsdl_path
      case @environment
      when :production
        'https://webpay3g.transbank.cl/WSWebpayTransaction/cxf/WSWebpayService?wsdl'
      when :certification
        'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSWebpayService?wsdl'
      when :integration
        'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSWebpayService?wsdl'
      else
        raise WebpayRails::InvalidEnvironment
      end
    end
  end
end
