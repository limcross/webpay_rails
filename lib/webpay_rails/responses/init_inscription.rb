module WebpayRails::Responses
  class InitInscription < WebpayRails::Response
    def self.attr_list
      [:token, :url_webpay]
    end

    attr_accessor(*attr_list)
  end
end
