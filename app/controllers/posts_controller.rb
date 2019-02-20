class PostsController < ApplicationController
  def index
  end

  def show
    $id = params['id']
    @detail = SlornApis.new.get_product_detail($id)

    if @detail['ticket_billing'] == '都度課金'
      @detail['ticket_billing'] = '<div hidden></div>'
    else
      @detail['ticket_billing'] = "<br/>このチケットは" + @detail['ticket_billing'] + "となります。"
    end

  end

  #購入
  def create

    if user_signed_in?
      flash[:notice] = "customer_id:" + current_user.customer_id.to_s + ",name:" + current_user.name
      @res = SlornApis.new.post_robot_payment(1,2)
      
      redirect_to posts_show_path
    else
      flash[:notice] = "ログインしてください"
      redirect_to posts_show_path
    end
  end


end
