class PostsController < ApplicationController
  def index
  end

  def show

    #はじめは、パラメータにid,pr_codeがある。
    #購入ボタンを押した時には、id,pr_codeがない。

    if params[:post_id].present?
      session[:post_id] = params[:post_id]
      @payment = SlornApis.new.get_payment_info(session[:post_id])

#{"status"=>1, "result"=>{
# "pr_code"=>"123",
# "aid"=>115406,
# "jb"=>"CAPTURE",
# "pt"=>1,
# "cmd"=>1}, "code"=>"1001", "message"=>"lang::pr code was found."}
      session[:pr_code] = @payment['result']['pr_code']
      session[:aid] = @payment['result']['aid']
      session[:jb] = @payment['result']['jb']
      session[:pt] = @payment['result']['pt']
      session[:cmd] = @payment['result']['cmd']
    end

    @phone_number = ''


    if current_user
      #電話番号を取得する
      @result = SlornApis.new.find_email_web(current_user.email)
      if @result['result']['phone_number'] != nil
        @phone_number = @result['result']['phone_number']
      end
    end

   @detail = SlornApis.new.get_product_detail(session[:post_id])

   @html = @detail['metadata']['ticket_caption']
   @html_strip = Sanitize.clean(@html, tags:[])

   set_meta_tags ({title: @detail['title'],
           description: @detail['ticket_caption'],
           og: {title: @detail['title']['rendered'],
                type: 'website',
                description: @html_strip,
                site_name: 'Slorn WEB',
                image: {_: @detail['ticket_image_url'], width: 400, height: 400}}});


   @shops = SlornApis.new.get_shops_web(session[:post_id])
   @shop_images = []
   for shops in @shops['result'] do
     @shop_images.push("https://s3-ap-northeast-1.amazonaws.com/test-s3.slorn.jp/pub/shoplogo/origin/" + shops["icon"] + "/200x200.jpg")
   end

    # if params['shop_images'] != nil
    #   @shop_images = params['shop_images']
    #   $shop_images = @shop_images
    # else
    #   #グローバル変数から取得
    #   @shop_images = $shop_images
    # end

    if @detail['ticket_billing'] == '都度課金'
      @detail['ticket_billing'] = '<div hidden></div>'
    else
      @detail['ticket_billing'] = "<br/>このチケットは" + @detail['ticket_billing'] + "となります。"
    end

    customer_id = "99999"
    email = "hoge@example.com"

    if current_user != nil
      customer_id = current_user.customer_id
      email = current_user.email
    end

    @cod = customer_id + "x" + session[:pr_code]
    @customer_id = customer_id
    @em = email


    # @aid = "116389"
    # @pt = "1"
    # @jb = "CAPTURE"
    # @cmd = "2"
    # @cod = customer_id + "x" + session[:pr_code]
    # @customer_id = customer_id
    # @iid = session[:pr_code]
    # @pr_code = session[:pr_code]
    # @em = email

    if user_signed_in?
      # ログインしている時は、購入ボタンを消し、postのボタンを表示する
      @show_buy_button = false
    else
      @show_buy_button = true
    end

  end

  #購入
  def create
    if user_signed_in?
      #購入ボタンを隠す
      @show_buy_button = true
      redirect_to posts_show_path
    else
      @show_buy_button = false
      flash[:notice] = "ログインまたは新規登録してください"
      redirect_to posts_show_path
    end
  end


end
