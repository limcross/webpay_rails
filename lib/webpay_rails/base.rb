module WebpayRails
  module Base
    extend ActiveSupport::Concern
    module ClassMethods
      # Setup a model for use Webpay Rails.
      #
      # ==== Variations of #webpay_rails
      #
      #   # setup with certificates and private_key content
      #   webpay_rails(
      #     commerce_code: 123456789,
      #     private_key: '-----BEGIN RSA PRIVATE KEY-----
      #   ...
      #   -----END RSA PRIVATE KEY-----',
      #     public_cert: '-----BEGIN CERTIFICATE-----
      #   ...
      #   -----END CERTIFICATE-----',
      #     webpay_cert: '-----BEGIN CERTIFICATE-----
      #   ...
      #   -----END CERTIFICATE-----',
      #     environment: :integration,
      #     log: true
      #   )
      #
      #   # setup with certificates and private_key files
      #   webpay_rails(
      #     commerce_code: 123456789,
      #     private_key: 'absolute/path/to/private_key.key',
      #     public_cert: 'absolute/path/to/public_cert.crt',
      #     webpay_cert: 'absolute/path/to/webpay_cert.crt',
      #     environment: :integration,
      #     log: true
      #   )
      def webpay_rails(args)
        class_attribute :vault, :soap_normal, :soap_nullify, :soap_oneclick,
                        instance_accessor: false

        self.vault = args[:vault] = WebpayRails::Vault.new(args)
        self.soap_normal = WebpayRails::SoapNormal.new(args)
        self.soap_nullify = WebpayRails::SoapNullify.new(args)
        self.soap_oneclick = WebpayRails::SoapOneclick.new(args)
      end

      # Initializes a transaction
      # Returns a WebpayRails::Response::InitTransaction if successfully initialised.
      # If fault a WebpayRails::RequestFailed exception is raised.
      # If the SOAP response cant be verified a WebpayRails::InvalidCertificate
      # exception is raised.
      #
      # === Arguments
      # [:amount]
      #   An integer that define the amount of the transaction.
      # [:buy_order]
      #   An string that define the order number of the buy.
      # [:session_id]
      #   An string that define a local variable that will be returned as
      #   part of the result of the transaction.
      # [:return_url]
      #   An string that define the url that Webpay redirect after client is
      #   authorized (or not) by the bank  for get the result of the transaction.
      # [:final_url]
      #   An string that define the url that Webpay redirect after they show
      #   the webpay invoice, or cancel the transaction from Webpay.
      def init_transaction(args)
        response = soap_normal.init_transaction(args)

        WebpayRails::Responses::InitTransaction.new(response)
      end

      # Retrieves the result of a transaction
      # Returns a WebpayRails::Response::TransactionResult if successfully get a response.
      # If fault a WebpayRails::RequestFailed exception is raised.
      # If the SOAP response cant be verified a WebpayRails::InvalidCertificate
      # exception is raised.
      #
      # === Arguments
      # [:token]
      #   An string that responds Webpay when redirect to +return_url+.
      # [:ack]
      #   An optional boolean with which you can disable the auto
      #   acknowledgement (I guess if you do this, you will know what you do).
      def transaction_result(args)
        response = soap_normal.get_transaction_result(args)

        acknowledge_transaction(args) if args[:ack] != false

        WebpayRails::Responses::TransactionResult.new(response)
      end

      # Reports the correct reception of the result of the transaction
      # If fault a WebpayRails::RequestFailed exception is raised.
      # If the SOAP response cant be verified a WebpayRails::InvalidCertificate
      # exception is raised.
      #
      # === Arguments
      # [:token]
      #   An string that responds Webpay when redirect to +return_url+.
      #
      # NOTE: It is not necessary to use this method because it is consumed by
      # +transaction_result+.
      def acknowledge_transaction(args)
        soap_normal.acknowledge_transaction(args)
      end

      # Nullify a transaction
      # Returns a WebpayRails::Response::TransactionNullify if successfully initialised.
      # If fault a WebpayRails::RequestFailed exception is raised.
      # If the SOAP response cant be verified a WebpayRails::InvalidCertificate
      # exception is raised.
      #
      # === Arguments
      # [:authorization_code]
      #   An string that original belongs to the transaction.
      # [:authorize_amount]
      #   An integer that define the original amount of the transaction.
      # [:buy_order]
      #   An string that define the order number of the transaction to be
      #   nullified.
      # [:nullify_amount]
      #   An intenger that define the amount to be nullified on the transaction.
      def nullify(args)
        response = soap_nullify.nullify(args)

        WebpayRails::Responses::TransactionNullify.new(response)
      end

      def init_inscription(args)
        response = soap_oneclick.init_inscription(args)

        WebpayRails::Responses::InitInscription.new(response)
      end

      def finish_inscription(args)
        response = soap_oneclick.finish_inscription(args)

        WebpayRails::Responses::FinishInscription.new(response)
      end

      def authorize(args)
        response = soap_oneclick.authorize(args)

        WebpayRails::Responses::Authorization.new(response)
      end

      def reverse(args)
        response = soap_oneclick.reverse(args)

        WebpayRails::Responses::Reverse.new(response)
      end

      def remove_user(args)
        response = soap_oneclick.remove_user(args)

        WebpayRails::Responses::RemoveUser.new(response)
      end
    end
  end
end
