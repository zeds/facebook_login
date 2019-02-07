require 'rqrcode'
require 'rqrcode_png'
require 'chunky_png' # to_data_urlはchunky_pngのメソッド

class MypagesController < ApplicationController
  before_action :authenticate_user!

  def index

    customer_id = 16
    customer_id = current_user.customer_id

    @result = SlornApis.new.get_customer_key_web(customer_id)

    @code = 'customer_key:' + @result['result']

    @id = current_user.customer_id
    @name = current_user.name

  end

end
