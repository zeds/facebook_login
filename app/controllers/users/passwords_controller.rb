class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  def new
    super
  end

  # POST /resource/password
  def create

    email = resource_params['email']
    @result = SlornApis.new.find_email_web(email)

    # emailが存在しない。
    if @result["status"] == 0
      flash[:notice] = "emailが存在しません"
      redirect_to new_user_password_path
    else

      # resourceを作成しないと、reset_password_instruction.html.erbで
      # post_idを取得できない
      my_sign_up_params = {}
      my_sign_up_params["email"] = email
      my_sign_up_params["password"] = "sign_up_password"
      my_sign_up_params["name"] = @result["result"]["name"]
      my_sign_up_params["post_id"] = session[:post_id]
      # 重複チェックされているかわからないのだが、同じレコードが存在するとき上書きされている？
      self.resource = resource_class.new_with_session(my_sign_up_params, session)
      self.resource.skip_confirmation!
      self.resource.save

      user = User.find_by(email: email)

      if user != nil
        user.destroy
      end

      # Slorn WEBにレコードを作成する
      customer_id = @result['result']['id']
      name = @result["result"]["name"]
      user = User.create_email_user(email, customer_id, name, "sign_up_password")
      # user.post_id を設定しないと、reset_password_instructionの@resource.post_idが
      # 取得できなかった。
      user.post_id = session[:post_id]
      user.save

      self.resource = resource_class.send_reset_password_instructions(resource_params)
      yield resource if block_given?

      if successfully_sent?(resource)

        if @user.present?
          respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
        else
          flash[:notice] = "ERROR:create_email_user"
          redirect_to new_user_password_path
        end
      else
        respond_with(resource)
        
      end

      # emailがSlorn DBにあって、Slorn WEBにない場合、レコードを作成してしまう。
      # 存在するものとして、Deviseがメールを送ってくれる
    end

  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit

    # post_idが設定されていたら、$post_idに格納する
    post_id = params['post_id'];

    if post_id != nil
      session[:post_id] = post_id
    else
      session[:post_id] = ""
    end

    super
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    yield resource if block_given?


    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)

      if Devise.sign_in_after_reset_password
        # Slorn DBのパスワードを更新する
        user = User.find_by(email: self.resource.email)
        customer_id = user.customer_id
        password = resource_params['password']
        digest = Digest::MD5.hexdigest(password)

        @result = SlornApis.new.update_customer_web(customer_id,nil,digest)

        # emailが存在しない。
        if @result["status"] == 0
          flash[:notice] = "error : update_customer_web"
          redirect_to new_user_password_path
        else

          flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
          set_flash_message!(:notice, flash_message)
          resource.after_database_authentication

          sign_in(resource_name, resource)
        end
      else
        set_flash_message!(:notice, :updated_not_active)
      end

      # 詳細から来た時は、post_idのページを開く
      if session[:post_id] != ""
        redirect_to posts_show_path(id: session[:post_id])
      else
        respond_with resource, location: after_resetting_password_path_for(resource)
      end
    else
      set_minimum_password_length
      respond_with resource
    end
  end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  def resource_params
    params.require(:user).permit(:email, :password, :password_confirmation, :reset_password_token, :post_id)
  end
  private :resource_params
end
