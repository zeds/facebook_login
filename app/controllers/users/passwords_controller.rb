# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  def new
    super
  end

  # POST /resource/password
  def create
    # super
    # return

    email = resource_params['email']
    @result = SlornApis.new.find_email_web(email)


    # emailが存在しない。
    if @result["status"] == 0
      flash[:notice] = "emailが存在しません"
      redirect_to new_user_password_path
    else

      my_sign_up_params = {}
      my_sign_up_params["email"] = email
      my_sign_up_params["password"] = "sign_up_password"
      my_sign_up_params["name"] = @result["result"]["name"]
      self.resource = resource_class.new_with_session(my_sign_up_params, session)
      self.resource.skip_confirmation!
      self.resource.save

      #passwordを再送するには、Slorn WEBにUserレコードが必要
      #customer_idを追加する
      @user = User.find_by(email: email)
      @user.customer_id = @result['result']['id']
      @user.save

      # customer_id = @result['result']['id']
      # @user = User.create_email_user(email,customer_id)

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
        end


        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message!(:notice, flash_message)
        resource.after_database_authentication
        sign_in(resource_name, resource)
      else
        set_flash_message!(:notice, :updated_not_active)
      end
      respond_with resource, location: after_resetting_password_path_for(resource)
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
end
