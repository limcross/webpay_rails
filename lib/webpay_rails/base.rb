module WebpayRails
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      def webpay_rails(args)
        class_attribute :vault, :soap_normal, :soap_nullify,
                        instance_accessor: false

        self.vault = args[:vault] = WebpayRails::Vault.new(args)
        self.soap_normal = WebpayRails::SoapNormal.new(args)
        self.soap_nullify = WebpayRails::SoapNullify.new(args)
      end

      def init_transaction(args)
        begin
          response = soap_normal.init_transaction(args)
        rescue Savon::SOAPFault => error
          raise WebpayRails::FailedInitTransaction, error.to_s
        end

        WebpayRails::Transaction.new(Nokogiri::HTML(response.to_s))
      end

      def transaction_result(token)
        begin
          response = soap_normal.get_transaction_result(token)
        rescue Savon::SOAPFault => error
          raise WebpayRails::FailedGetResult, error.to_s
        end

        raise WebpayRails::InvalidResultResponse if response.blank?

        acknowledge_transaction(token)

        WebpayRails::TransactionResult.new(Nokogiri::HTML(response.to_s))
      end

      def acknowledge_transaction(token)
        begin
          response = soap_normal.acknowledge_transaction(token)
        rescue Savon::SOAPFault => error
          raise WebpayRails::FailedAcknowledgeTransaction, error.to_s
        end

        raise WebpayRails::InvalidAcknowledgeResponse if response.blank?
      end

      def nullify(args)
        begin
          response = soap_nullify.nullify(args)
        rescue Savon::SOAPFault => error
          raise WebpayRails::FailedNullify, error.to_s
        end

        WebpayRails::TransactionNullified.new(Nokogiri::HTML(response.to_s))
      end
    end
  end
end
