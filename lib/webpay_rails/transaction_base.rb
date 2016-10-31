module WebpayRails
  class TransactionBase
    def initialize(response)
      document = Nokogiri::HTML(response.to_s)
      self.class.attr_list.each do |k|
        v = document.at_xpath("//#{k.to_s.tr('_', '')}")
        send("#{k}=", v.text.to_s) unless v.nil?
      end
    end
  end
end
