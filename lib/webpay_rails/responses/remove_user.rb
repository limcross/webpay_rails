module WebpayRails::Responses
  class RemoveUser < WebpayRails::Response
    def self.attr_list
      [:return]
    end

    attr_accessor(*attr_list)

    def success?
      self.return == 'true'
    end
  end
end
