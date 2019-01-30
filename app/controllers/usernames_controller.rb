class UsernamesController < ApplicationController
  def index
  end

  def create


    # validation 1文字以上。
    $name = params[:name]

    # debugger

    user = User.new(
      uid:      $uid,
      provider: $provider,
      email:    $email,
      name:  $name,
      password: "hogehoge"
      # password: Devise.friendly_token[0, 20],
      # image:  auth.info.image
    )


    if user.save
      flash[:notice] = "お帰りなさい"
      sign_in(user, scope: :user)
      redirect_to mypages_index_path, success: 'flash.blogs.create'
    else
      # saveできなかった場合 nickname画面
      flash[:notice] = "usernameが正しくありません。4文字以上"
      redirect_to names_index_path
    end


  end
end
