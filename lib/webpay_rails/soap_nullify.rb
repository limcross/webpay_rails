module WebpayRails
  class SoapNullify < Soap
    def nullify(authorization_code, authorize_amount, buy_order, commerce_code, nullify_amount)
      request = client.build_request(:nullify, message: {
        authorizationCode: authorization_code, authorizeAmount: authorize_amount,
        buyOrder: buy_order, commerceCode: commerce_code, nullifyAmount: nullify_amount
      })

      call(request, :nullify)
    end

    private

    def wsdl_path
      case @environment
      when :production
        'https://webpay3g.transbank.cl/WSWebpayTransaction/cxf/WSCommerceIntegrationService?wsdl'
      when :certification
        'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSCommerceIntegrationService?wsdl'
      when :integration
        'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSCommerceIntegrationService?wsdl'
      else
        raise WebpayRails::InvalidEnvironment
      end
    end
  end
end
