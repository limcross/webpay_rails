module WebpayRails
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      def webpay_rails(options)
        class_attribute :commerce_code, :webpay_cert, :environment, :soap, instance_accessor: false

        self.commerce_code = options[:commerce_code]
        self.webpay_cert = OpenSSL::X509::Certificate.new(options[:webpay_cert])
        self.environment = options[:environment]

        self.soap = WebpayRails::Soap.new(options)
      end

      def init_transaction(amount, buy_order, session_id, return_url, final_url)
        begin
          response = soap.init_transaction(commerce_code, amount, buy_order, session_id, return_url, final_url)
        rescue StandardError
          raise WebpayRails::FailedInitTransaction
        end

        raise WebpayRails::InvalidCertificate unless WebpayRails::Verifier.verify(response, webpay_cert)

        document = Nokogiri::HTML(response.to_s)
        WebpayRails::Transaction.new({
          token: document.at_xpath('//token').text.to_s,
          url: document.at_xpath('//url').text.to_s
        })
      end

      def transaction_result(token)
        begin
          response = soap.get_transaction_result(token)
        rescue StandardError
          raise WebpayRails::FailedGetResult
        end

        raise WebpayRails::InvalidResultResponse unless response

        acknowledge_transaction(token)

        document = Nokogiri::HTML(response.to_s)
        WebpayRails::TransactionResult.new({
          accounting_date: document.at_xpath('//accountingdate').text.to_s,
          buy_order: document.at_xpath('//buyorder').text.to_s,
          card_number: document.at_xpath('//cardnumber').text.to_s,
          amount: document.at_xpath('//amount').text.to_s,
          commerce_code: document.at_xpath('//commercecode').text.to_s,
          authorization_code: document.at_xpath('//authorizationcode').text.to_s,
          payment_type_code: document.at_xpath('//paymenttypecode').text.to_s,
          response_code: document.at_xpath('//responsecode').text.to_s,
          transaction_date: document.at_xpath('//transactiondate').text.to_s,
          url_redirection: document.at_xpath('//urlredirection').text.to_s,
          vci: document.at_xpath('//vci').text.to_s
        })
      end

      def acknowledge_transaction(token)
        begin
          response = soap.acknowledge_transaction(token)
        rescue StandardError
          raise WebpayRails::FailedAcknowledgeTransaction
        end

        raise WebpayRails::InvalidAcknowledgeResponse unless response
      end
    end
  end
end
