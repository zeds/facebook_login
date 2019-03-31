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
    customer_id = current_user["customer_id"]
    current_password = params["user"]["current_password"]
    password = params["user"]["password"]
    password_confirmation = params["user"]["password_confirmation"]

    if current_password.length == 0 || password.length == 0 || password_confirmation == 0
      flash[:notice] = "空の項目があります"
    else
      if password.length < Devise.password_length.min || password_confirmation.length < Devise.password_length.min
        flash[:notice] = "パスワードは" + Devise.password_length.min.to_s + "文字以上にしてください"
      else
        # 現在のパスワードが正しいか調べる
        @user = User.find_by_id(current_user.id)
        current_digest = Digest::MD5.hexdigest(current_password)

        if @user.encrypted_password != current_digest
          flash[:notice] = "現在のパスワードが正しくありません"
        else
          # customer_id : 778
          digest = Digest::MD5.hexdigest(password)
          @result = SlornApis.new.update_customer_web(current_user.customer_id,nil,digest)

          if @result["status"] == 0
            flash[:notice] = "error : update_customer_web"
          else
            # d487
            if password != password_confirmation
              flash[:notice] = "確認パスワードが一致しません"
            else
              @user.encrypted_password = digest
              @user.save
              flash[:notice] = "パスワードを更新しました"
            end
          end
        end
      end
    end

    redirect_to password_edit_path

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

    @result = SlornApis.new.find_email_web(email)


    if @result["status"] == 1
      flash[:notice] = "emailアドレスは既に登録されています。ログインしてください。"
      redirect_to new_user_session_path and return
    end

    user = User.find_by(email: email)
    if user != nil
      user.destroy
    end

    my_sign_up_params = {}
    my_sign_up_params["email"] = email
    my_sign_up_params["password"] = password
    my_sign_up_params["name"] = name
    my_sign_up_params["post_id"] = session[:post_id]

    self.resource = resource_class.new_with_session(my_sign_up_params, session)
    # self.resource.skip_confirmation!
    self.resource.save
    # build_resource(my_sign_up_params)

    yield resource if block_given?
    if resource.persisted?
      # if resource.active_for_authentication?
      #   set_flash_message! :notice, :signed_up
      #   sign_up(resource_name, resource)
      #   respond_with resource, location: after_sign_up_path_for(resource)
      # else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      # end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end

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
