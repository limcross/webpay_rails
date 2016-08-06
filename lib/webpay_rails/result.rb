module WebpayRails
  class Result
    attr_reader :accounting_date, :buy_order, :card_number, :amount, :commerce_code,
      :authorization_code, :payment_type_code, :response_code, :transaction_date,
      :url_redirection, :vci

    def initialize(params)
      @accounting_date = params[:accounting_date]
      @buy_order = params[:buy_order]
      @card_number = params[:card_number]
      @amount = params[:amount]
      @commerce_code = params[:commerce_code]
      @authorization_code = params[:authorization_code]
      @payment_type_code = params[:payment_type_code]
      @response_code = params[:response_code]
      @transaction_date = params[:transaction_date]
      @url_redirection = params[:url_redirection]
      @vci = params[:vci]
    end
  end
end
