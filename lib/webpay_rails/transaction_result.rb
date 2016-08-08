module WebpayRails
  class TransactionResult
    attr_reader :accounting_date, :buy_order, :card_number, :amount, :commerce_code,
      :authorization_code, :payment_type_code, :response_code, :transaction_date,
      :url_redirection, :vci

    def initialize(args)
      @accounting_date = args[:accounting_date]
      @buy_order = args[:buy_order]
      @card_number = args[:card_number]
      @amount = args[:amount]
      @commerce_code = args[:commerce_code]
      @authorization_code = args[:authorization_code]
      @payment_type_code = args[:payment_type_code]
      @response_code = args[:response_code]
      @transaction_date = args[:transaction_date]
      @url_redirection = args[:url_redirection]
      @vci = args[:vci]
    end

    def approved?
      @response_code == 0
    end
  end
end
