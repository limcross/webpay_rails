module WebpayRails
  # Generic WebpayRails exception class.
  class WebpayRailsError < StandardError; end

  # Raise when the commerce code has not been defined.
  class MissingCommerceCode < WebpayRailsError; end
  # Raise when the environment is not valid.
  class InvalidEnvironment < WebpayRailsError; end

  # Generic Soap exception class.
  class SoapError < WebpayRailsError
    def initialize(action, error)
      super("Attempted to #{action} but #{error}")
    end
  end

  # Raise when the SOAP request has failed.
  class RequestFailed < SoapError
    def initialize(action, error)
      super(action, "SOAP responds with a #{error.http.code} " \
                    "status code: #{error}")
    end
  end
  # Raise when the SOAP response of a request is blank.
  class InvalidResponse < SoapError
    def initialize(action)
      super(action, 'SOAP response is blank')
    end
  end
  # Raise when the SOAP response cannot be verify with the webpay cert.
  class InvalidCertificate < SoapError
    def initialize(action)
      super(action, 'the response was not signed with the correct certificate')
    end
  end

  # Generic Vault exception class.
  class VaultError < WebpayRailsError; end

  # Raise when vault cant load the file.
  class FileNotFound < VaultError; end
  # Raise when private key has not been defined.
  class MissingPrivateKey < VaultError; end
  # Raise when public certificate has not been defined.
  class MissingPublicCertificate < VaultError; end
  # Raise when webpay certificate has not been defined.
  class MissingWebpayCertificate < VaultError; end
end
