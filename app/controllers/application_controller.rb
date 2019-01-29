class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :warning, :danger

  def after_sign_in_path_for(resource_or_scope)
    mypages_index_path
  end
end
