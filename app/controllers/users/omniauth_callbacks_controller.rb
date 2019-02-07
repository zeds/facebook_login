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

    # @user = User.check_user_for_oauth(auth)
    @result = SlornApis.new.find_provider_web(uid,'FB',email)

    # user = User.create(
    #   uid:      auth.uid,
    #   provider: auth.provider,
    #   email:    auth.info.email,
    #   name:  auth.info.name,
    #   password: Devise.friendly_token[0, 20],
    #   image:  auth.info.image
    # )

    # facebook より取得
    $uid = auth.uid
    $provider = auth.provider
    $email = auth.info.email
    $name = auth.info.name

    logger.debug "******* omniauth ******"


    # Userが存在する場合、MyPagesへ
    # 存在しない場合、username入力画面へ
    if @user.present?
      flash[:notice] = "お帰りなさい"
      sign_in(@user, scope: :user)

      redirect_to mypages_index_path, success: 'flash.blogs.create'
    else
      flash[:notice] = "ご新規のお客様ですね。店員さんに何と呼ばれたいですか？ *1文字以上"
      redirect_to names_index_path
    end

    return

    provider = provider.to_s

# 認証に成功したら、情報をDBに書き込んでいる。
# このタイミングでは、書き込みたくない。
    @user = User.find_for_oauth(request.env['omniauth.auth'])

    if @user.persisted?
      flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: provider.capitalize)
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.#{provider}_data"] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
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
