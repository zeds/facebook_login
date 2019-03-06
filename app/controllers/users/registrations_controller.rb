# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:name]) //追加した
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:description]) //追加した
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end


  def password_edit
  end

  def password_update
    debugger
    customer_id = current_user["customer_id"]
    current_password = params["user"]["current_password"]
    
    # "current_password"=>"", "password"=>"", "password_confirmation"=>""



  end

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create

    email = sign_up_params['email']
    password = sign_up_params['password']
    name = sign_up_params['name']

    # @result = SlornApis.new.login_email_web("maedamin+20190130@gmail.com","hogehoge")
    @result = SlornApis.new.find_email_web(email,password)

    if @result["status"] == 1
      flash[:notice] = "emailアドレスは既に登録されています。ログインしてください。"
      redirect_to new_user_session_path
      return
    end

    super
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
