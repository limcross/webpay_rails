module WebpayRails
  class Transaction
    def self.attr_list
      [:token, :url]
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
