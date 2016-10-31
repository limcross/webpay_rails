class OrdersController < ActionController::Base
  before_action :find_order, only: [:return, :final]

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(create_params)

    if @order.save
      if init_transaction
        render :gateway
      else
        @order.update(status: :failed)
        render :failed
      end
    else
      render action: :new
    end
  end

  def return
    if transaction_result && @order.update(update_params) && @result.approved?
      @method = :get
      @url = @result.url_redirection
      @token = params[:token_ws]
      @order.update(status: :approved)
      render :gateway
    else
      @order.update(status: :failed)
      render :failed
    end
  end

  def final
    if @order.approved?
      render :success
    else
      render :failed
    end
  end

  private

  def find_order
    @order = Order.find(params[:id])
  end

  def create_params
    params.require(:order).permit(:amount)
  end

  def update_params
    {
      tbk_token_ws: params[:token_ws],
      tbk_accounting_date: @result.accounting_date,
      tbk_buy_order: @result.buy_order,
      tbk_card_number: @result.card_number,
      tbk_commerce_code: @result.commerce_code,
      tbk_authorization_code: @result.authorization_code,
      tbk_payment_type_code: @result.payment_type_code,
      tbk_response_code: @result.response_code,
      tbk_transaction_date: @result.transaction_date,
      tbk_vci: @result.vci,
      tbk_session_id: @result.session_id,
      tbk_card_expiration_date: @result.card_expiration_date,
      tbk_shares_number: @result.shares_number,
      amount: @result.amount
    }
  end

  def verify_order
    render :failed if @order.approved?
  end

  def init_transaction
    transaction = Order.init_transaction(init_transaction_params)
    if transaction.success?
      @method = :post
      @url = transaction.url
      @token = transaction.token
    end

    transaction.success?
  rescue WebpayRails::SoapError
    false
  end

  def transaction_result
    @result = Order.transaction_result(token: params[:token_ws])
    true
  rescue WebpayRails::SoapError
    false
  end

  def init_transaction_params
    {
      amount: @order.amount,
      buy_order: @order.id,
      session_id: session.id,
      return_url: url_for(action: :return, id: @order.id),
      final_url: url_for(action: :final, id: @order.id)
    }
  end
end
