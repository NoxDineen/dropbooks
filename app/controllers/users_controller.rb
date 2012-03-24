class UsersController < ApplicationController
  def freshbooks_authorize
    request_token = freshbooks_client.get_request_token(oauth_callback:
      freshbooks_authorize_callback_url)
    session[:freshbooks_token] = request_token.token
    session[:freshbooks_secret] = request_token.secret
    session[:freshbooks_account] = params[:account]
    redirect_to request_token.authorize_url
  end

  def freshbooks_authorize_callback
    access_token = freshbooks_client.get_access_token(
      session[:freshbooks_token],
      session[:freshbooks_secret],
      params[:oauth_verifier])

    user = User.find_or_create_by_freshbooks_account(freshbooks_account,
      freshbooks_token: access_token.token,
      freshbooks_secret: access_token.secret)

    # sign this user in
    cookies.permanent.signed[:token] = user.token

    redirect_to root_path
  end

private
  def freshbooks_client
    @freshbooks_client ||= Dropbooks.create_freshbooks_client(freshbooks_account)
  end

  def freshbooks_account
    params[:account] || session[:freshbooks_account]
  end
end
