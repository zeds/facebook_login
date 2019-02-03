require "addressable/uri"
require 'net/https'
require 'erb'
include ERB::Util

class SlornApis
  def login_email_web(email, password, retry_count = 10)
    raise ArgumentError, 'too many HTTP redirects' if retry_count == 0

    # addressableのencodeで+が%2bにエンコードされなかったので。
    email = url_encode(email)
    url = "https://staging-c-api.slorn.jp/v2.0.1/login_email_web?email=#{email}&password=#{password}"

    uri = Addressable::URI.parse(url)
    # uri.port の値は設定されていないが問題ないよう

    # debugger

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
            nil
          else
            json
          end
        when Net::HTTPRedirection
          location = response['location']
          Rails.logger.error(warn "redirected to #{location}")
        else
          Rails.logger.error([uri.to_s, response.value].join(" : "))
      end
    rescue => e
      Rails.logger.error(e.message)
      raise e
    end
  end
end
