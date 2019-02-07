module ApplicationHelper


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
