module WebpayRails
  class TransactionNullified
    def self.attr_list
      [:token, :authorization_code, :authorization_date, :balance,
       :nullified_amount]
    end

    def initialize(document)
      self.class.attr_list.each do |k|
        v = document.at_xpath("//#{k.to_s.tr('_', '')}")
        send("#{k}=", v.text.to_s) unless v.nil?
      end
    end

    def success?
      !token.blank?
    end

    attr_reader(*attr_list)

    private

    attr_writer(*attr_list)
  end
end
