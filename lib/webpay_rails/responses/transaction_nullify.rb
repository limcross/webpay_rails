module WebpayRails::Responses
  class TransactionNullify < WebpayRails::Response
    def self.attr_list
      [:token, :authorization_code, :authorization_date, :balance,
       :nullified_amount]
    end

    attr_accessor(*attr_list)

    def success?
      !token.blank?
    end
  end
end
