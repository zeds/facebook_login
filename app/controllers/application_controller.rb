class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :warning, :danger
  before_action   :configure_permitted_parameters, if: :devise_controller?
  before_action   :store_current_location, unless: :devise_controller?

  #登録完了後のリダイレクト先の変更
  def after_sign_in_path_for(resource_or_scope)
    mypages_index_path
  end

  def after_sign_out_path_for(resource_or_scope)
    homes_path
  end

  def store_current_location

    # session[:user_return_to]
    # store_location_for(:user, request.url)
    Rails.logger.error("*******************")
    Rails.logger.error(request.fullpath)
    Rails.logger.error(new_user_session_path)
    Rails.logger.error("*******************")

    if (request.fullpath != new_user_session_path)
        # # request.fullpath != "/users/password" &&
        # request.fullpath !~ Regexp.new("\\A/users/password.*\\z") ||
        # !request.xhr?)
      # session[:return_to] = request.fullpath
      store_location_for(:user, request.url)
      Rails.logger.error("@@@@@@@@@@@@@@@@")
      Rails.logger.error(session[:user_return_to])
      Rails.logger.error("@@@@@@@@@@@@@@@@")
    end
  end


  protected
  def configure_permitted_parameters
      added_attrs = [ :name, :email, :password, :password_confirmation, :post_id　]
      devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
      devise_parameter_sanitizer.permit :account_update, keys: added_attrs
      devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
  end
end
