# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  protect_from_forgery except: [:new,:create] # searchアクションを除外

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create

    email = sign_in_params['email']
    password = sign_in_params['password']
    remember_me = sign_in_params['remember_me']

    @result = SlornApis.new.login_email_web(email,password)

    # emailが存在しない。
    if @result["status"] == 0
      flash[:notice] = I18n.t('devise.failure.not_found_in_database')
      redirect_to new_user_session_path
      return
    end

    $customer_id = @result['result']['id']
    $email = @result['result']['email']
    $name = @result['result']['name']

    user = User.find_by(email: $email)

    if user != nil
      user.destroy
    end

    # Slorn WEBにレコードを作成する
    user = User.create_email_user($email, $customer_id, $name, password)

    sign_in(user, scope: :user)

    if session[:user_return_to] != nil
      redirect_to session[:user_return_to]
    else
      redirect_to mypages_index_path, notice: 'お帰りなさい'
    end

    # super
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
