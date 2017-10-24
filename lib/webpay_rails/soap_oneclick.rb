module WebpayRails
  class SoapOneclick < Soap
    def init_inscription(args)
      request = client.build_request(:init_inscription,
                                     message: init_inscription_message(args))

      call(request, :init_inscription)
    end

    def finish_inscription(args)
      request = client.build_request(:finish_inscription,
                                     message: finish_inscription_message(args))

      call(request, :finish_inscription)
    end

    def authorize(args)
      request = client.build_request(:authorize,
                                     message: authorize_message(args))

      call(request, :authorize)
    end

    def reverse(args)
      request = client.build_request(:reverse,
                                     message: reverse_message(args))

      call(request, :reverse)
    end

    def remove_user(args)
      request = client.build_request(:remove_user,
                                     message: remove_user_message(args))

      call(request, :remove_user)
    end

    private

    def wsdl_path
      case @environment
      when :production
        'https://webpay3g.transbank.cl/webpayserver/wswebpay/OneClickPaymentService?wsdl'
      when :certification, :integration
        'https://webpay3gint.transbank.cl/webpayserver/wswebpay/OneClickPaymentService?wsdl'
      end
    end

    def init_inscription_message(args)
      {
        arg0: {
          email: args[:email],
          responseURL: args[:return_url],
          username: args[:username]
        }
      }
    end

    def finish_inscription_message(args)
      {
        arg0: {
          token: args[:token]
        }
      }
    end

    def authorize_message(args)
      {
        arg0: {
          buyOrder: args[:buy_order],
          tbkUser: args[:tbk_user],
          username: args[:username],
          amount: args[:amount]
        }
      }
    end

    def reverse_message(args)
      {
        arg0: {
          buyorder: args[:buy_order]
        }
      }
    end

    def remove_user_message(args)
      {
        arg0: {
          tbkUser: args[:tbk_user],
          username: args[:username]
        }
      }
    end
  end
end
