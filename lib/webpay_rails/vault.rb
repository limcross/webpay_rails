module WebpayRails
  class Vault
    def initialize(args)
      args.map { |k, v| send("#{k}=", v) if respond_to? k }

      raise WebpayRails::MissingPrivateKey unless @private_key
      raise WebpayRails::MissingWebpayCertificate unless @webpay_cert
      raise WebpayRails::MissingPublicCertificate unless @public_cert
    end

    attr_reader :webpay_cert, :private_key, :public_cert

    private

    def webpay_cert=(cert)
      @webpay_cert ||= OpenSSL::X509::Certificate.new(read(cert))
    end

    def private_key=(key)
      @private_key ||= OpenSSL::PKey::RSA.new(read(key))
    end

    def public_cert=(cert)
      @public_cert ||= OpenSSL::X509::Certificate.new(read(cert))
    end

    def read(val)
      return val if val.include? '-----BEGIN'

      path = Pathname.new(val)
      return path.read if path.file?

      raise WebpayRails::FileNotFound, val
    end
  end
end
