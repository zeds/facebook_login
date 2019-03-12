# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController


  def facebook
    callback_from :facebook
  end

  private

  def callback_from(provider)

    # uid,providerが存在するか確認している
    auth = request.env['omniauth.auth']
    $uid = auth.uid
    $provider = 'FB'
    $email = auth.info.email
    $name = auth.info.name

    # @user = User.check_user_for_oauth(auth)
    @result = SlornApis.new.find_provider_web($uid,'FB',$email)

    if @result['status'] == 1
      flash[:notice] = "お帰りなさい"

      my_sign_up_params = {}
      my_sign_up_params["email"] = $email
      my_sign_up_params["password"] = "sign_up_password"
      my_sign_up_params["name"] = $name
      # 重複チェックされているかわからないのだが、同じレコードが存在するとき上書きされている？
      self.resource = resource_class.new_with_session(my_sign_up_params, session)
      self.resource.skip_confirmation!
      self.resource.save

      #passwordを再送するには、Slorn WEBにUserレコードが必要
      #customer_idを追加する
      @user = User.find_by(email: $email)
      @user.customer_id = @result['result']['id']
      @user.save
      sign_in(@user, scope: :user)

      if session[:user_return_to] != nil
        redirect_to session[:user_return_to]
      else
        redirect_to mypages_index_path
      end

    else
      flash[:notice] = "ご新規のお客様ですね。店員さんに何と呼ばれたいですか？ *1文字以上"
      redirect_to names_index_path(uid: $uid, email: $email)
    end

  end
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
