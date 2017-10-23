class OneclickOrdersController < ActionController::Base
  def new
    @order = Order::Oneclick.new
  end

  def create
    @user = User.first!
    @order = Order::Oneclick.create!(create_params)
    @response = Order::Oneclick.authorize(authorize_params)
    if @response.success?
      @order.update!(update_params)
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
      tbk_response_code: @response.response_code,
      tbk_authorization_code: @response.authorization_code,
      tbk_transaction_id: @response.transaction_id,
      tbk_last_4_card_digits: @response.last_4_card_digits,
      tbk_credit_card_type: @response.credit_card_type
    }
  end
end
