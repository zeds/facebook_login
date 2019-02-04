# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show

    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    email = self.resource.email
    password = self.resource.encrypted_password
    name = self.resource.name
    uid = nil
    provider = nil

    # str = ["hogehoge", self.resource.password_salt].flatten.compact.join
    # digest = Digest::MD5.hexdigest(str)

    @result = SlornApis.new.register_customer_web(email, password, name, uid, provider)

    # 成功
    if @result["status"] == 1
      flash[:notice] = "Slornへの登録が完了しました。ログインできます。"
      redirect_to new_user_session_path
      return
    end

    flash[:notice] = "register_customer_webでエラーが発生しました"
    super
  end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
end
