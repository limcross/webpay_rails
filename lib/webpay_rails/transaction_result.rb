module WebpayRails
  class TransactionResult < TransactionBase
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

    def approved?
      response_code.to_i.zero?
    end

    attr_reader(*attr_list)

    private

    attr_writer(*attr_list)
  end
end
