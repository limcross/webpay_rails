module WebpayRails
  class Transaction
    attr_reader :token, :url

    def initialize(params)
      @token = params[:token]
      @url = params[:url]
      @valid_cert = params[:valid_cert]
    end

    def success?
      @token
    end
  end
end
