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

    Rails.logger.error("=== find_provider_web ===")
    Rails.logger.error(@result)

    if @result['status'] == 1

      $customer_id = @result["result"]["id"]
      $name = @result["result"]["name"]

      flash[:notice] = "お帰りなさい"

      #エラー処理していない
      @user = User.sign_in_with_facebook($email,$customer_id,$name)
      sign_in(@user, scope: :user)

      # 詳細から来た時は、post_idのページを開く
      if $post_id != nil
        redirect_to posts_show_path(id: $post_id)
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
