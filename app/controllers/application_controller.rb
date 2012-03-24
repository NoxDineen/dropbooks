class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :current_user?

  def require_freshbooks_authorization
    redirect_to root_path unless current_user?
  end

  def require_dropbox_authorization
    if current_user? and !current_user.dropbox_authorized?
      redirect_to dropbox_authorize_path
    end
  end

  def current_user?
    !current_user.nil?
  end

  def current_user
    @current_user ||= begin
      token = cookies.signed[:token]
      User.find_by_token(token) if token
    end
  end
end
