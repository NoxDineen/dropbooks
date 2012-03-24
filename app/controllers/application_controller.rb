class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :current_user?

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
