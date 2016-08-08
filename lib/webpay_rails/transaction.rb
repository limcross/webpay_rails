module WebpayRails
  class Transaction
    attr_reader :token, :url

    def initialize(args)
      @token = args[:token]
      @url = args[:url]
    end

    def success?
      !@token.blank?
    end
  end
end
