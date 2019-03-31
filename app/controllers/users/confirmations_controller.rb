# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  def create
    Rails.logger.info("** confirmation create **")



    email = resource_params["email"]

    binding.pry

    #追加
    my_resource_params = {}
    my_resource_params["email"] = email
    my_resource_params["password"] = nil
    my_resource_params["name"] = nil
    my_resource_params["post_id"] = session[:post_id]
    self.resource = resource_class.new_with_session(my_resource_params, session)
    self.resource.skip_confirmation!
    self.resource.save

    user = User.find_by(email: email)
    if user == nil
      flash[:notice] = "emailが存在しません"
      redirect_to new_user_confirmation_path and return
    end

    user.post_id = session[:post_id]
    user.save


    self.resource = resource_class.send_confirmation_instructions(resource_params)
    yield resource if block_given?


    if successfully_sent?(resource)
      respond_with({}, location: after_resending_confirmation_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end

    # super
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show

    Rails.logger.info("** confirmation show **")

    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    email = self.resource.email
    encrypted_password = self.resource.encrypted_password
    name = self.resource.name
    uid = nil
    provider = nil

    @result = SlornApis.new.register_customer_web(email, encrypted_password, name, uid, provider)

    # 成功
    if @result["status"] == 1

      # ログイン状態にする
      customer_id = @result['result'];
      user = User.find_by(email: email)

      if user != nil
        user.destroy
      end

      user = User.create_email_user(email, customer_id, name, encrypted_password)
      sign_in(user, scope: :user)

      flash[:notice] = "Slornへの登録が完了しました"

      # 詳細から来た時は、post_idのページを開く
      if params[:post_id].present?
        session[:post_id] = params[:post_id]
        redirect_to posts_show_path(post_id: session[:post_id])
      else
        redirect_to mypages_index_path
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
  def resource_params
    params.require(:user).permit(:email, :password, :password_confirmation, :reset_password_token, :post_id)
  end
  private :resource_params

end
