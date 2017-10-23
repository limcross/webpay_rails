module WebpayRails
  module Responses
    class InitTransaction < WebpayRails::Response
      def self.attr_list
        [:token, :url]
      end

      attr_accessor(*attr_list)

      def success?
        !token.blank?
      end
    end
  end
end
