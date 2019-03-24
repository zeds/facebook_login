# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  def create
    super
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show

    post_id = params['post_id'];

    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    email = self.resource.email
    password = self.resource.encrypted_password
    name = self.resource.name
    uid = nil
    provider = nil

    @result = SlornApis.new.register_customer_web(email, password, name, uid, provider)

    # 成功
    if @result["status"] == 1


      # ログイン状態にする
      customer_id = @result['result'];
      user = User.find_by(email: email)

      if user != nil
        user.destroy
      end

      user = User.create_email_user(email, customer_id, name, password)
      sign_in(user, scope: :user)

      flash[:notice] = "Slornへの登録が完了しました"

      # 詳細から来た時は、post_idのページを開く
      if post_id != nil
        redirect_to posts_show_path(id: post_id)
      else
        redirect_to root_path
      end
    else
      flash[:notice] = "register_customer_webでエラーが発生しました"
      super
    end

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
