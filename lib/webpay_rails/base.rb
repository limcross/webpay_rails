module WebpayRails
  module Base
    extend ActiveSupport::Concern

    included do
      def webpay_rails(options)
        class_attribute :webpay_options

        self.webpay_options = {
          wsdl_path: options.wsdl_path || 'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSWebpayService?wsdl',
          commerce_code: options.commerce_code,
          private_key: OpenSSL::PKey::RSA.new(options.private_key),
          public_cert: OpenSSL::X509::Certificate.new(options.public_cert),
          webpay_cert: OpenSSL::X509::Certificate.new(options.webpay_cert),
          environment: options.environment
        }

        @client = Savon.client(wsdl: self.webpay_options[:wsdl_path])
      end

      def init_transaction(amount, buyOrder, sessionId, return_url, final_url)
        req = @client.build_request(:init_transaction, message: {
          wsInitTransactionInput: {
            wSTransactionType: 'TR_NORMAL_WS',
            buyOrder: buyOrder,
            sessionId: sessionId,
            returnURL: return_url,
            finalURL: final_url,
            transactionDetails: {
              amount: amount,
              commerceCode: self.webpay_options[:commerce_code],
              buyOrder: buyOrder
            }
          }
        })

        # sign document
        document = self.sign_xml(req)
        puts document

        begin
          response = @client.call(:init_transaction) do
            xml document.to_xml(save_with: 0)
          end
        rescue Exception, RuntimeError
          raise
        end

        token = ''
        response_document = Nokogiri::HTML(response.to_s)
        response_document.xpath('//token').each do |token_value|
          token = token_value.text
        end

        url = ''
        response_document.xpath('//url').each do |url_value|
          url = url_value.text
        end

        puts "token: #{token}"
        puts "url: #{url}"

        # verify cert
        tbk_cert = OpenSSL::X509::Certificate.new(self.webpay_options[:webpay_cert])

        unless WebpayRails::Verifier.verify(response, tbk_cert)
          puts "El Certificado es Invalido."
        else
          puts "El Certificado es Valido."
        end

        response_array = {
          token: token.to_s,
          url: url.to_s
        }
      end

      def get_result(token)
        # prepare sign
        req = @client.build_request(:get_transaction_result, message: {
          tokenInput: token
        })

        # sign request
        document = self.sign_xml(req)

        # begining get result
        begin
          puts "Iniciando GetResult..."
          response = @client.call(:get_transaction_result) do
            xml document.to_xml(:save_with => 0)
          end
        rescue Exception, RuntimeError
          raise
        end

        # we review that response is not nil
        if response
          puts "Respuesta getResult: #{response.to_s}"
        else
          puts 'Webservice Webpay responde con null'
        end

        token_obtenido = '' # FIXME ??
        response_document = Nokogiri::HTML(response.to_s)

        accountingdate 		= response_document.xpath('//accountingdate').text
        buyorder 					= response_document.xpath('//buyorder').text
        cardnumber 				= response_document.xpath('//cardnumber').text
        amount 						= response_document.xpath('//amount').text
        commercecode 			= response_document.xpath('//commercecode').text
        authorizationcode	= response_document.xpath('//authorizationcode').text
        paymenttypecode 	= response_document.xpath('//paymenttypecode').text
        responsecode 			= response_document.xpath('//responsecode').text
        transactiondate 	= response_document.xpath('//transactiondate').text
        urlredirection 		= response_document.xpath('//urlredirection').text
        vci 							= response_document.xpath('//vci').text

        # acknowledge
        acknowledge_transaction(token)

        {
          accountingdate: 		 accountingdate.to_s,
          buyorder: 					 buyorder.to_s,
          cardnumber: 				 cardnumber.to_s,
          amount: 						 amount.to_s,
          commercecode: 			 commercecode.to_s,
          authorizationcode:	 authorizationcode.to_s,
          paymenttypecode: 	   paymenttypecode.to_s,
          responsecode: 			 responsecode.to_s,
          transactiondate: 	   transactiondate.to_s,
          urlredirection: 		 urlredirection.to_s,
          vci: 							   vci.to_s
        }
      end

    private

      def acknowledge_transaction(token)
        # prepare sign
        req = @client.build_request(:acknowledge_transaction, message: {
          tokenInput: token
        })

        # sign body of request
        document = self.sign_xml(req)

        # acknowledge_transaction
        begin
          puts "Iniciando acknowledge_transaction..."
          response = @client.call(:acknowledge_transaction, message: acknowledgeInput) do
            xml document.to_xml(:save_with => 0)
          end
        rescue Exception, RuntimeError
          raise
        end

        # we review that response is not nil
        if response
          puts "Respuesta acknowledge_transaction: #{response.to_s}"
        else
          puts 'Webservice Webpay responde con null'
        end
      end
    end

    module ClassMethods
    private
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
end
