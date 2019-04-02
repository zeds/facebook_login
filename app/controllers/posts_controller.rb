class PostsController < ApplicationController
  def index
  end

  def show

    #はじめは、params[:post_id]がある
    #購入ボタンを押した時には、params[:post_id]がない

    #confirmからきた時は、session[:post_id]

    Rails.logger.info("*** posts/show***********")


    if params[:post_id].present?
      session[:post_id] = params[:post_id]
    end

  Rails.logger.info("session[:post_id]="+session[:post_id])
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


    @detail = SlornApis.new.get_product_detail(session[:post_id])



    @phone_number = ''


    if current_user
      #電話番号を取得する
      @result = SlornApis.new.find_email_web(current_user.email)
      if @result['result']['phone_number'] != nil
        @phone_number = @result['result']['phone_number']
      end
    end

   @detail = SlornApis.new.get_product_detail(session[:post_id])

   Rails.logger.info("**************")
   Rails.logger.info("ticket_caption" + @detail['ticket_caption'])


   @html = @detail['ticket_caption']
   @html_kaigyou = @html.gsub(/\r\n|\r|\n/, "")
   @html_strip = Sanitize.clean(@html_kaigyou, tags:[])


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

    # <input name="pn" type="HIDDEN" value="<%= @phone_number %>" />
    # <input name="aid" type="HIDDEN" value=<%= session[:aid] %> />
    # <input name="pt" type="HIDDEN" value=<%= session[:pt] %> />
    # <input name="jb" type="HIDDEN" value=<%= session[:jb] %> />
    # <input name="cod" type="HIDDEN" value=<%= @cod %> />
    # <input name="cmd" type="HIDDEN" value=<%= session[:cmd] %> />
    # <input name="iid" type="HIDDEN" value=<%= session[:pr_code] %> />
    # <input name="customer_id" type="HIDDEN" value="<%= @customer_id %>" />
    # <input name="em" type="HIDDEN" value=<%= @em %> />
    # <input name="pr_code" type="HIDDEN" value=<%= session[:pr_code] %> />
    Rails.logger.info("pn:"+@phone_number)
    Rails.logger.info("aid:"+session[:aid].to_s)
    Rails.logger.info("pt:"+session[:pt].to_s)
    Rails.logger.info("jb:"+session[:jb].to_s)
    Rails.logger.info("cod:"+@cod)
    Rails.logger.info("cmd:"+session[:cmd].to_s)
    Rails.logger.info("iid:"+session[:pr_code].to_s)
    Rails.logger.info("customer_id:"+@customer_id)
    Rails.logger.info("em:"+@em)
    Rails.logger.info("pr_code:"+session[:pr_code].to_s)

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
      flash[:notice] = "「購入」の際はChrome、IE、Safari等の専用ブラウザをご利用ください。"
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
