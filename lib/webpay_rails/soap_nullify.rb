module WebpayRails
  class SoapNullify < Soap
    def nullify(args)
      request = client.build_request(:nullify, message: nullify_message(args))

      call(request, :nullify)
    end

    private

    def wsdl_path
      case @environment
      when :production
        'https://webpay3g.transbank.cl/WSWebpayTransaction/cxf/WSCommerceIntegrationService?wsdl'
      when :certification, :integration
        'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSCommerceIntegrationService?wsdl'
      end
    end

    def nullify_message(args)
      {
        authorizationCode: args[:authorization_code],
        authorizeAmount: args[:authorize_amount],
        buyOrder: args[:buy_order],
        commerceCode: @commerce_code,
        nullifyAmount: args[:nullify_amount]
      }
    end
  end
end
