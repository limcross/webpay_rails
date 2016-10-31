module WebpayRails
  class TransactionNullified < TransactionBase
    def self.attr_list
      [:token, :authorization_code, :authorization_date, :balance,
       :nullified_amount]
    end

    def success?
      !token.blank?
    end

    attr_reader(*attr_list)

    private

    attr_writer(*attr_list)
  end
end
