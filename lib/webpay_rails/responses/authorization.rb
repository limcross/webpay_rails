module WebpayRails::Responses
  class Authorization < WebpayRails::Response
    def self.attr_list
      [:response_code, :authorization_code, :transaction_id,
       :last_4_card_digits, :credit_card_type]
    end

    attr_accessor(*attr_list)
  end
end
