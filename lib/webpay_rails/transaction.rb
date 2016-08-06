module WebpayRails
  class Transaction
    attr_reader :token, :url

    def initialize(params)
      @token = params[:token]
      @url = params[:url]
    end

    def success?
      !@token.blank?
    end
  end
end
