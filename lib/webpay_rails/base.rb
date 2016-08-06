module WebpayRails
  module Base
    extend ActiveSupport::Concern

    included do
      def webpay_rails(options)
        class_attribute :webpay_options
        class_attribute :client

        self.webpay_options = {
          wsdl_path: options.wsdl_path || 'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSWebpayService?wsdl',
          commerce_code: options.commerce_code,
          private_key: OpenSSL::PKey::RSA.new(options.private_key),
          public_cert: OpenSSL::X509::Certificate.new(options.public_cert),
          webpay_cert: OpenSSL::X509::Certificate.new(options.webpay_cert),
          environment: options.environment
        }

        self.client = Savon.client(wsdl: self.webpay_options[:wsdl_path])
      end

      def init_transaction(amount, buy_order, session_id, return_url, final_url)
        request = self.client.build_request(:init_transaction, message: {
          wsInitTransactionInput: {
            wSTransactionType: 'TR_NORMAL_WS',
            buyOrder: buy_order,
            sessionId: session_id,
            returnURL: return_url,
            finalURL: final_url,
            transactionDetails: {
              amount: amount,
              commerceCode: self.webpay_options[:commerce_code],
              buyOrder: buy_order
            }
          }
        })

        document = WebpayRails::Base.sign_xml(request)
        begin
          response = self.client.call(:init_transaction) do
            xml(document.to_xml(save_with: 0))
          end
        rescue Exception, RuntimeError
          raise WebpayRails::FailedInitTransaction
        end

        tbk_cert = OpenSSL::X509::Certificate.new(self.webpay_options[:webpay_cert])

        raise WebpayRails::InvalidCertificate unless WebpayRails::Verifier.verify(response, tbk_cert)

        response_document = Nokogiri::HTML(response.to_s)

        WebpayRails::Transaction.new({
          token: response_document.at_xpath('//token').text.to_s,
          url: response_document.at_xpath('//url').text.to_s
        })
      end

      def get_result(token)
        request = self.client.build_request(:get_transaction_result, message: {
          tokenInput: token
        })

        document = WebpayRails::Base.sign_xml(request)
        begin
          response = self.client.call(:get_transaction_result) do
            xml(document.to_xml(:save_with => 0))
          end
        rescue Exception, RuntimeError
          raise WebpayRails::FailedGetResult
        end

        raise WebpayRails::InvalidResultResponse unless response

        acknowledge_transaction(token)

        response_document = Nokogiri::HTML(response.to_s)

        WebpayRails::Result.new({
          accounting_date: response_document.at_xpath('//accountingdate').text.to_s,
          buy_order: response_document.at_xpath('//buyorder').text.to_s,
          card_number: response_document.at_xpath('//cardnumber').text.to_s,
          amount: response_document.at_xpath('//amount').text.to_s,
          commerce_code: response_document.at_xpath('//commercecode').text.to_s,
          authorization_code: response_document.at_xpath('//authorizationcode').text.to_s,
          payment_type_code: response_document.at_xpath('//paymenttypecode').text.to_s,
          response_code: response_document.at_xpath('//responsecode').text.to_s,
          transaction_date: response_document.at_xpath('//transactiondate').text.to_s,
          url_redirection: response_document.at_xpath('//urlredirection').text.to_s,
          vci: response_document.at_xpath('//vci').text.to_s
        })
      end

    private

      def acknowledge_transaction(token)
        request = self.client.build_request(:acknowledge_transaction, message: {
          tokenInput: token
        })

        document = WebpayRails::Base.sign_xml(request)

        begin
          response = self.client.call(:acknowledge_transaction, message: acknowledgeInput) do
            xml document.to_xml(:save_with => 0)
          end
        rescue Exception, RuntimeError
          raise WebpayRails::FailedAcknowledgeTransaction
        end

        raise WebpayRails::InvalidAcknowledgeResponse unless response
      end
    end

    def sign_xml(input_xml)
      document = Nokogiri::XML(input_xml.body)
      envelope = document.at_xpath('//env:Envelope')
      envelope.prepend_child('<env:Header><wsse:Security xmlns:wsse=\'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\' wsse:mustUnderstand=\'1\'/></env:Header>')
      xml = document.to_s

      signer = Signer.new(xml)

      signer.cert = OpenSSL::X509::Certificate.new(self.webpay_options[:public_cert])
      signer.private_key = OpenSSL::PKey::RSA.new(self.webpay_options[:private_key])

      signer.document.xpath('//soapenv:Body', { soapenv: 'http://schemas.xmlsoap.org/soap/envelope/' }).each do |node|
        signer.digest!(node)
      end

      signer.sign!(:issuer_serial => true)
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
  end
end
