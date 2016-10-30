module WebpayRails
  # Generic WebpayRails exception class.
  class WebpayRailsError < StandardError; end

  # Raise when the commerce code has not been defined
  class MissingCommerceCode < WebpayRailsError; end
  # Raise when the environment is not valid
  class InvalidEnvironment < WebpayRailsError; end

  # Raise when the init_transaction method has failed
  class FailedInitTransaction < WebpayRailsError; end

  # Raise when the transaction_result method has failed
  class FailedGetResult < WebpayRailsError; end
  # Raise when the transaction_result method result in a blank response
  class InvalidResultResponse < WebpayRailsError; end

  # Raise when the acknowledge_transaction method has failed
  class FailedAcknowledgeTransaction < WebpayRailsError; end
  # Raise when the acknowledge_transaction method result in a blank response
  class InvalidAcknowledgeResponse < WebpayRailsError; end
  # Raise when the response cant ve verify with the webpay cert
  class InvalidCertificate < WebpayRailsError; end

  # Raise when the nullify method has failed
  class FailedNullify < WebpayRailsError; end

  # Raise when vault cant load the file
  class FileNotFound < WebpayRailsError; end
  # Raise when private key has not been defined
  class MissingPrivateKey < WebpayRailsError; end
  # Raise when public certificate has not been defined
  class MissingPublicCertificate < WebpayRailsError; end
  # Raise when webpay certificate has not been defined
  class MissingWebpayCertificate < WebpayRailsError; end
end
