# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController


  def facebook
    callback_from :facebook
  end

  private

  def callback_from(provider)

    # user_data = request.env['omniauth.auth']
    # logger.debug "user_data=" + user_data.to_s
    # session[:name] = user_data[:info][:name]
    # redirect_to root_path, notice: 'ログインしました'


    # auth=#<OmniAuth::AuthHash credentials=#<OmniAuth::AuthHash expires=true expires_at=1553746904 token="EAAOdBnGgNQMBAPZAsxM2ZCS5v5ZAZCKbGTxAXAQyDYhybDsUC4MRisKUERLTk4IXlhvaFE8u2XyRDPoc0EBNk0ZBA3iKKJ5EXK1dPTASNfABzdvmKxnWzo9UMyPF4sWFAGMwdcGk6IQmMS2IWm1GuCy7Fea9pbAEZD"> extra=#<OmniAuth::AuthHash raw_info=#<OmniAuth::AuthHash
    # email="tom_z39@yahoo.co.jp" id="10156939163661460" name="Tsutomu Okumura">> info=#<OmniAuth::AuthHash::InfoHash
    # email="tom_z39@yahoo.co.jp" image="http://graph.facebook.com/v2.10/10156939163661460/picture"
    # name="Tsutomu Okumura"> provider="facebook" uid="10156939163661460">


    # uid,providerが存在するか確認している
    auth = request.env['omniauth.auth']
    uid = auth.uid
    provider = 'FB'
    email = auth.info.email
    name = auth.info.name

    # uid = '10155098615466460'
    # digest = Digest::MD5.hexdigest(uid)

    # @user = User.check_user_for_oauth(auth)
    @result = SlornApis.new.find_provider_web(uid,'FB',email)

    if @result['status'] == 1
      flash[:notice] = "お帰りなさい"

      my_sign_up_params = {}
      my_sign_up_params["email"] = email
      my_sign_up_params["password"] = "sign_up_password"
      my_sign_up_params["name"] = name
      # 重複チェックされているかわからないのだが、同じレコードが存在するとき上書きされている？
      self.resource = resource_class.new_with_session(my_sign_up_params, session)
      self.resource.skip_confirmation!
      self.resource.save

      #passwordを再送するには、Slorn WEBにUserレコードが必要
      #customer_idを追加する
      @user = User.find_by(email: email)
      @user.customer_id = @result['result']['id']
      @user.save
      sign_in(@user, scope: :user)

      redirect_to mypages_index_path, success: 'flash.blogs.create'
    else
      flash[:notice] = "ご新規のお客様ですね。店員さんに何と呼ばれたいですか？ *1文字以上"
      redirect_to names_index_path
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
