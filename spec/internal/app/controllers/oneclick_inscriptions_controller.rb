class OneclickInscriptionsController < ActionController::Base
  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)
    @response = Order::Oneclick.init_inscription(init_inscription_params)

    @method = :post
    @url = @response.url_webpay
    @token = @response.token

    render :gateway
  rescue WebpayRails::SoapError
    render :failed
  end

  def finish
    @user = User.find(params[:user_id])
    @response = Order::Oneclick.finish_inscription(finish_inscription_params)
    if @response.success?
      @user.update(tbk_user: @response.tbk_user)
      render :success
    else
      render :failed
    end
  rescue WebpayRails::SoapError
    render :failed
  end

  private

  def user_params
    params.require(:user).permit(:username, :email)
  end

  def init_inscription_params
    user_params.merge(return_url: url_for(action: :finish, user_id: @user.id))
  end

  def finish_inscription_params
    {
      token: params[:TBK_TOKEN]
    }
  end
end
