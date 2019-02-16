class PostsController < ApplicationController
  def index
  end

  def show
    response.headers.delete "X-Frame-Options"
    $id = params['id']
    @result = SlornApis.new.get_post_from_wordpress($id)
  end

  #購入
  def create

    if user_signed_in?
      flash[:notice] = "customer_id:" + current_user.customer_id.to_s + ",name:" + current_user.name
      redirect_to posts_show_path
    else
      flash[:notice] = "ログインしてください"
      redirect_to posts_show_path
    end
  end


end
