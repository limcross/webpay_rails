module WebpayRails::Responses
  class FinishInscription < WebpayRails::Response
    def self.attr_list
      [:response_code, :auth_code, :tbk_user, :last_4_card_digits,
       :credit_card_type]
    end

    attr_accessor(*attr_list)

    def success?
      response_code.to_i.zero?
    end
  end
end
