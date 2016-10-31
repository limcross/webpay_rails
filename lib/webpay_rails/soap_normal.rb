module WebpayRails
  class SoapNormal < Soap
    def init_transaction(args)
      request = client.build_request(:init_transaction,
                                     message: init_transaction_message(args))

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

    private

    def wsdl_path
      case @environment
      when :production
        'https://webpay3g.transbank.cl/WSWebpayTransaction/cxf/WSWebpayService?wsdl'
      when :certification, :integration
        'https://webpay3gint.transbank.cl/WSWebpayTransaction/cxf/WSWebpayService?wsdl'
      end
    end

    def init_transaction_message(args)
      {
        wsInitTransactionInput: {
          wSTransactionType: 'TR_NORMAL_WS',
          buyOrder: args[:buy_order],
          sessionId: args[:session_id],
          returnURL: args[:return_url],
          finalURL: args[:final_url],
          transactionDetails: {
            amount: args[:amount],
            commerceCode: @commerce_code,
            buyOrder: args[:buy_order]
          }
        }
      }
    end
  end
end
