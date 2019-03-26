require "addressable/uri"
require 'net/https'
require 'erb'
include ERB::Util

class SlornApis

  def post_robot_payment(customer_id, email)
    url = "https://credit.j-payment.co.jp/gateway/payform.aspx"
    uri = Addressable::URI.parse(url)
    uri.port = 443
    # インスタンスを生成
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    http.ssl_version = 'TLSv1'  #        -- or SSLv3, but TLSv1 is better
    http.ciphers = ['RC4-SHA']
    #送りたいデータを格納
    params = {
      aid: '116389',
      pt: '1',
      jb: 'CAPTURE',
      cod: '16',
      iid: '234',
      customer_id: '16',
      em: 'mm0607@hotmail.com',
      pr_code: '234'
    }

    headers = { "Content-Type": "application/json" }
    response = Net::HTTP::Post.new(uri)
    request.body = params.to_json

    #send request
    response = http.request(request)

    response.code # status code
    response.body # response body

  end

  def get_product_detail(post_id)
    url = "https://slorn.jp/wp-json/wp/v2/ticket/#{post_id}"
    uri = Addressable::URI.parse(url)

    json = call_http_wordpress(uri)
    Rails.logger.error(json)

    return json

  end

  def get_shops_web(post_id)
    url = "https://staging-c-api.slorn.jp/v2.0.1/get_shops_web?post_id=#{post_id}"
    uri = Addressable::URI.parse(url)
    uri.port = 443

    json = call_http(uri)
    Rails.logger.error(json)

    return json
  end


  def get_available_products
    url = "https://staging-c-api.slorn.jp/v2.0.1/get_available_products"
    uri = Addressable::URI.parse(url)
    uri.port = 443

    json = call_http(uri)
    Rails.logger.error(json)

    return json
  end

  def get_post_from_wordpress(post_id)
    url = "https://slorn.jp/wp-json/wp/v2/posts/#{post_id}"
    uri = Addressable::URI.parse(url)

    json = call_http_wordpress(uri)
    Rails.logger.error(json)

    return json

  end

  def get_all_my_ticket_web(customer_id)
    email = url_encode(email)
    url = "https://staging-c-api.slorn.jp/v2.0.1/get_all_my_ticket_web?customer_id=#{customer_id}"
    uri = Addressable::URI.parse(url)
    uri.port = 443

    json = call_http(uri)
    Rails.logger.error(json)

    return json

  end

  def update_customer_web(customer_id, email, password)

    email = url_encode(email)
    url = "https://staging-c-api.slorn.jp/v2.0.1/update_customer_web?customer_id=#{customer_id}&email=#{email}&password=#{password}"
    uri = Addressable::URI.parse(url)
    uri.port = 443

    json = call_http(uri)
    Rails.logger.error(json)

    return json
  end

  def get_customer_key_web(customer_id, retry_count = 10)
    raise ArgumentError, 'too many HTTP redirects' if retry_count == 0

    url = "https://staging-c-api.slorn.jp/v2.0.1/get_customer_key_web?customer_id=#{customer_id}"
    uri = Addressable::URI.parse(url)
    uri.port = 443

    json = call_http(uri)
    Rails.logger.error(json)

    return json
  end

  def register_customer_web(email, password, name, uid, provider, retry_count = 10)
    raise ArgumentError, 'too many HTTP redirects' if retry_count == 0

    email = url_encode(email)
    name = url_encode(name)
    url = "https://staging-c-api.slorn.jp/v2.0.1/register_customer_web?email=#{email}&password=#{password}&name=#{name}&uid=#{uid}&provider=#{provider}"
    uri = Addressable::URI.parse(url)
    uri.port = 443

    json = call_http(uri)
    Rails.logger.error(json)

    return json
  end

  def find_email_web(email, retry_count = 10)
    raise ArgumentError, 'too many HTTP redirects' if retry_count == 0
    # addressableのencodeで+が%2bにエンコードされなかったので。
    email = url_encode(email)
    url = "https://staging-c-api.slorn.jp/v2.0.1/find_email_web?email=#{email}"
    uri = Addressable::URI.parse(url)
    uri.port = 443

    json = call_http(uri)
    Rails.logger.error(json)

    return json
  end

  def find_provider_web(uid, provider, email, retry_count = 10)
    raise ArgumentError, 'too many HTTP redirects' if retry_count == 0

    email = url_encode(email)
    url = "https://staging-c-api.slorn.jp/v2.0.1/find_provider_web?uid=#{uid}&provider=#{provider}&email=#{email}"
    uri = Addressable::URI.parse(url)
    uri.port = 443

    json = call_http(uri)
    Rails.logger.error(json)

    return json

  end

  #probider = "FB"
  def login_email_web(email, password, retry_count = 10)
    raise ArgumentError, 'too many HTTP redirects' if retry_count == 0

# debug
    # email = "maedamin+20190130@gmail.com"
    # password = "hogehoge"

    digest = Digest::MD5.hexdigest(password)

    # addressableのencodeで+が%2bにエンコードされなかったので。
    email = url_encode(email)
    url = "https://staging-c-api.slorn.jp/v2.0.1/login_email_web?email=#{email}&password=#{digest}"
    uri = Addressable::URI.parse(url)
    uri.port = 443

    json = call_http(uri)
    Rails.logger.error(json)

    return json
  end

  def call_http(uri)

    begin
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme = 'https') do |http|
        http.open_timeout = 5
        http.read_timeout = 10
        http.get(uri.request_uri)
      end


      case response
        when Net::HTTPSuccess
          json = JSON.parse(response.body)

          if json['result'] == 0
            return nil
          else
            return json
          end
        when Net::HTTPRedirection
          location = response['location']
          Rails.logger.error(warn "redirected to #{location}")
        else
          # Rails.logger.error([uri.to_s, response.value].join(" : "))
          Rails.logger.error("見つかりませんでした！")
      end
    rescue => e
      Rails.logger.error(e.message)
      raise e
    end
  end

  def call_http_wordpress(uri)

    begin
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme = 'https') do |http|
        http.open_timeout = 5
        http.read_timeout = 10
        http.get(uri.request_uri)
      end


      case response
        when Net::HTTPSuccess
          json = JSON.parse(response.body)
          return json

        when Net::HTTPRedirection
          location = response['location']
          Rails.logger.error(warn "redirected to #{location}")
        else
          # Rails.logger.error([uri.to_s, response.value].join(" : "))
          Rails.logger.error("見つかりませんでした！")
      end
    rescue => e
      Rails.logger.error(e.message)
      raise e
    end
  end


end
