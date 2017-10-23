module WebpayRails::Responses
  class TransactionResult < WebpayRails::Response
    def self.attr_list
      [
        :buy_order, :session_id, :accounting_date, :transaction_date, :vci,
        :url_redirection,

        # card details
        :card_number, :card_expiration_date,

        # transaction details
        :authorization_code, :payment_type_code, :response_code,
        :amount, :shares_number, :commerce_code
      ]
    end

    attr_accessor(*attr_list)

    def approved?
      response_code.to_i.zero?
    end
  end
end
