module WebpayRails
  class SoapNormal < Soap
    def init_transaction(commerce_code, amount, buy_order, session_id, return_url, final_url)
      request = client.build_request(:init_transaction, message: {
        wsInitTransactionInput: {
          wSTransactionType: 'TR_NORMAL_WS', buyOrder: buy_order,
          sessionId: session_id, returnURL: return_url, finalURL: final_url,
          transactionDetails: {
            amount: amount, commerceCode: commerce_code, buyOrder: buy_order
          }
        }
      })

      call(request, :init_transaction)
    end

    def get_transaction_result(token)
      request = client.build_request(:get_transaction_result,
                                     message: { tokenInput: token })

      call(request, :get_transaction_result)
    end

    def acknowledge_transaction(token)
      request = client.build_request(:acknowledge_transaction,
                                     message: { tokenInput: token })

      call(request, :acknowledge_transaction)
    end

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
        'https://webpay3g.transbank.cl/WSWebpayTransaction/cxf/WSWebpayService?wsdl'
      when :certification
        'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSWebpayService?wsdl'
      when :integration
        'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSWebpayService?wsdl'
      else
        raise WebpayRails::InvalidEnvironment
      end
    end
  end
end
