# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create

    email = sign_in_params['email']
    password = sign_in_params['password']
    remember_me = sign_in_params['remember_me']

    # @result = SlornApis.new.login_email_web("maedamin+20190130@gmail.com","hogehoge")
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

    debugger

    user = User.find_by(email: $email)
    if user == nil
      # Slorn WEBにレコードを作成する
      user = User.create_email_user($email, $customer_id)
    end

    user.customer_id = $customer_id
    user.save

    sign_in(user, scope: :user)



    # Rails.logger.error(@result)
    redirect_to mypages_index_path, notice: 'お帰りなさい'

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
