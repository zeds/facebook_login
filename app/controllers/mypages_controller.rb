require 'rqrcode'
require 'rqrcode_png'
require 'chunky_png' # to_data_urlはchunky_pngのメソッド

class MypagesController < ApplicationController
  before_action :authenticate_user!

  def index

    @customer_id = current_user.customer_id
    @name = current_user.name

    @result = SlornApis.new.get_customer_key_web(@customer_id)

    @code = 'customer_key:' + @result['result']

    @tickets = SlornApis.new.get_all_my_ticket_web(@customer_id)
    # @tickets = SlornApis.new.get_all_my_ticket_web(16)


    if @tickets["status"] == 0
      flash[:notice] = "保有しているチケットはありません"
    else
      for ticket in @tickets["result"] do
        for shops in ticket["shops"] do
          shops['shop_icon'] = "https://s3-ap-northeast-1.amazonaws.com/test-s3.slorn.jp/pub/shoplogo/origin/" + shops["icon"] + "/200x200.jpg"
        end
      end
    end


  end

end
