class OneclickOrdersController < ActionController::Base
  def new
    @order = Order::Oneclick.new
  end

  def create
    @user = User.first!
    @order = Order::Oneclick.create!(create_params)
    @response = Order::Oneclick.authorize(authorize_params)
    if @response.success?
      @order.update!(update_params.merge(status: :approved))
      render :success
    else
      render :failed
    end
  rescue WebpayRails::SoapError
    render :failed
  end

  private

  def create_params
    params.require(:order_oneclick).permit(:amount)
  end

  def authorize_params
    {
      buy_order: @order.buy_order_for_transbank_oneclick,
      tbk_user: @user.tbk_user,
      username: @user.username,
      amount: @order.amount
    }
  end

  def update_params
    {
      #tbk_token_ws: '',
      #tbk_accounting_date: '',
      tbk_buy_order: @order.buy_order_for_transbank_oneclick,
      tbk_card_number: @response.last_4_card_digits,
      #tbk_commerce_code: '',
      tbk_authorization_code: @response.authorization_code,
      tbk_payment_type_code: 'VN',
      tbk_response_code: @response.response_code,
      #tbk_transaction_date: '',
      #tbk_vci: '',
      #tbk_session_id: '',
      #tbk_card_expiration_date: '',
      tbk_shares_number: 0,
      amount: @order.amount,

      tbk_transaction_id: @response.transaction_id,
      tbk_credit_card_type: @response.credit_card_type
    }
  end
end
