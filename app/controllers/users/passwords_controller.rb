# frozen_string_literal: true

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
      # emailがSlorn DBにあって、Slorn WEBにない場合、レコードを作成してしまう。
      # 存在するものとして、Deviseがメールを送ってくれる
      customer_id = @result['result']['id']
      @user = User.create_email_user(email,customer_id)
      if @user.present?
        super
      end
    end

  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    super
  end

  # PUT /resource/password
  def update

    # resource_params
    # <ActionController::Parameters
    # {"reset_password_token"=>"Hu1sjbj_28cxyTv-uUKD",
    # "password"=>"yellow", "password_confirmation"=>"yellow"} permitted: false>


    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?

#debug customer_idを取得しているが、current_userに入れたい
      @result = SlornApis.new.find_email_web(self.resource.email)

      customer_id = @result['result']['id']
      password = resource_params['password']
      digest = Digest::MD5.hexdigest(password)

      @result = SlornApis.new.update_customer_web(customer_id,nil,digest)

      #エラーハンドリング
      if @result["status"] == 0
        flash[:notice] = "update_customer_webでエラーが発生しました"
        redirect_to new_user_password_path
        return
      end

      #正常終了
      super
    else
      #パスワードは6文字以上に設定してください
      set_minimum_password_length
      respond_with resource
    end


    # super
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
