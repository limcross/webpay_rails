module WebpayRails
  class Soap
    extend Savon::Model

    def initialize(args)
      @vault = args[:vault]
      @environment = args[:environment] || :integration
      @commerce_code = args[:commerce_code]

      raise WebpayRails::MissingCommerceCode unless @commerce_code

      unless valid_environments.include? @environment
        raise WebpayRails::InvalidEnvironment
      end

      self.class.client(wsdl: wsdl_path, log: args[:log] || true,
                        logger: file_logger.extend(rails_logger))
    end

    private

    def call(request, operation)
      signed_document = sign_xml(request)

      response = client.call(operation) do
        xml signed_document.to_xml(save_with: 0)
      end

      verify_response(response, operation)
    rescue Savon::SOAPFault => error
      raise WebpayRails::RequestFailed.new(operation, error)
    end

    def sign_xml(input_xml)
      document = Nokogiri::XML(input_xml.body)
      envelope = document.at_xpath('//env:Envelope')
      envelope.prepend_child('<env:Header><wsse:Security xmlns:wsse=\'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\' wsse:mustUnderstand=\'1\'/></env:Header>')
      xml = document.to_s

      signer = Signer.new(xml)

      signer.cert = @vault.public_cert
      signer.private_key = @vault.private_key

      signer.document.xpath('//soapenv:Body', { soapenv: 'http://schemas.xmlsoap.org/soap/envelope/' }).each do |node|
        signer.digest!(node)
      end

      signer.sign!(issuer_serial: true)
      signed_xml = signer.to_xml

      document = Nokogiri::XML(signed_xml)
      x509data = document.at_xpath('//*[local-name()=\'X509Data\']')
      new_data = x509data.clone
      new_data.set_attribute('xmlns:ds', 'http://www.w3.org/2000/09/xmldsig#')

      n = Nokogiri::XML::Node.new('wsse:SecurityTokenReference', document)
      n.add_child(new_data)
      x509data.add_next_sibling(n)

      document
    end

    def verify_response(response, operation)
      raise(WebpayRails::InvalidResponse, operation) if response.blank?

      if WebpayRails::Verifier.verify(response, @vault.webpay_cert)
        response
      else
        raise WebpayRails::InvalidCertificate, operation
      end
    end

    def valid_environments
      [:production, :certification, :integration]
    end

    def rails_logger
      ActiveSupport::Logger.broadcast(WebpayRails.rails_logger)
    end

    def file_logger
      Logger.new(Rails.root.join("log/webpay_#{@commerce_code}.log"))
    end
  end
end
