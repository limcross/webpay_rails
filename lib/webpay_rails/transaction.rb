module WebpayRails
  class Transaction < TransactionBase
    def self.attr_list
      [:token, :url]
    end

    def success?
      !token.blank?
    end

    attr_reader(*attr_list)

    private

    attr_writer(*attr_list)
  end
end
