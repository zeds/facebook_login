class HomesController < ApplicationController
  def index
    session.delete(:user_return_to)

    @result = SlornApis.new.get_available_products

    @array = []
    @hash = {}

    #post_idを取得する
    for product in @result["result"]["products"] do
	     post_id = product["post_id"]

       #詳細を取得
       @detail = SlornApis.new.get_product_detail(post_id)

       #wordpressはエラーの時trueを返す
       if @detail == true
         # nothing to be done
       else
         @hash["id"] = @detail["id"]
         @hash["title"] = @detail["title"]

         @array_image = []
         for shops in product["shops"] do
           @array_image.push("https://s3-ap-northeast-1.amazonaws.com/test-s3.slorn.jp/pub/shoplogo/origin/" + shops["icon"] + "/200x200.jpg")
         end
         @hash["images"] = @array_image
         @hash["caption"] = @detail["ticket_caption"]
         @hash["price"] = @detail["ticket_price"]
         @hash["billing"] = @detail["ticket_billing"]
         @hash["period"] = @detail["ticket_period"]
         @array.push(@hash)
       end

    end


  end
end
