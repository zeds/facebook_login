class NamesController < ApplicationController
  def index

    $uid = params['uid']
    $email = params['email']

  end


  def create

    # validation 4文字以上。
    $name = params[:name]

    if $name.length == 0
      flash[:notice] = "お名前は1文字以上で登録してください"
      redirect_to names_index_path and return
    end

    @result = SlornApis.new.register_customer_web($email, Devise.friendly_token[0, 20], $name, $uid, "FB")

    # 成功
    if @result["status"] == 1
      #passwordを再送するには、Slorn WEBにUserレコードが必要
      #customer_idを追加する
      @user = User.find_by(email: $email)
      @user.customer_id = @result['result']
      @user.save
      sign_in(@user, scope: :user)

      flash[:notice] = "Slornへようこそ"
      redirect_to mypages_index_path
    else
      flash[:notice] = "ERROR : register_customer_web"
      redirect_to new_user_session_path and return
    end

  end
end
