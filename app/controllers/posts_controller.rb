class PostsController < ApplicationController
  def index
  end

  def show


    set_meta_tags ({title: 'タイトル',
            description: 'デスクリプション',
            og: {image: {_: 'https://s3-ap-northeast-1.amazonaws.com/test-s3.slorn.jp/pub/gift/origin/IS8yQPl6/384x384.jpg', width: 1200, height: 630}}});

    if params['id'] != nil
      $post_id = params['id']
    end

    if params['pr_code'] != nil
      $pr_code = params['pr_code']
    end

    @phone_number = ''

    if current_user
      #電話番号を取得する
      @result = SlornApis.new.find_email_web(current_user.email)
      if @result['result']['phone_number'] != nil
        @phone_number = @result['result']['phone_number']
      end
    end

   @detail = SlornApis.new.get_product_detail($post_id)

   @shops = SlornApis.new.get_shops_web($post_id)
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

    @aid = "116389"
    @pt = "1"
    @jb = "CAPTURE"
    @cmd = "2"
    @cod = customer_id + "x" + $pr_code
    @customer_id = customer_id
    @iid = $pr_code
    @pr_code = $pr_code
    @em = email

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
