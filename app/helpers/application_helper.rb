module ApplicationHelper

  def default_meta_tags
    {
      site: 'サイト名',
      title: 'タイトル',
      reverse: true,
      charset: 'utf-8',
      description: 'description',
      keywords: 'キーワード',
      canonical: request.original_url,
      separator: '|',
      og: {
        site_name: 'サイト名', # もしくは site_name: :site
        title: 'タイトル', # もしくは title: :title
        description: 'description', # もしくは description: :description
        type: 'website',
        url: request.original_url,
        image: image_url('https://s3-ap-northeast-1.amazonaws.com/test-s3.slorn.jp/pub/gift/origin/IS8yQPl6/384x384.jpg
'),
        locale: 'ja_JP',
      },
      twitter: {
        card: 'summary',
        site: '@ツイッターのアカウント名',
      }
    }
  end

  def qrcode_tag(text, options = {})
    ::RQRCode::QRCode.new(text).as_svg(options).html_safe
  end

  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger",
      alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |flash_type, message|
      concat(
        content_tag(:div, message, class: "alert alert-dismissable rounded-0 #{bootstrap_class_for(flash_type)}") do
          concat(
            content_tag(:button, class: "close", data: { dismiss: "alert" }) do
              concat content_tag(:span, "×".html_safe)
            end
          )
          concat message
        end
      )
    end
  end

  def flash_messages?
    if flash.present?
      true
    else
      false
    end
  end
end
