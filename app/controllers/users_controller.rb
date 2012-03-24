class UsersController < ApplicationController
  before_filter :require_freshbooks_authorization,
    except: [ :freshbooks_authorize, :freshbooks_authorize_callback, :freshbooks_callback ]

  skip_before_filter :verify_authenticity_token, only: [ :freshbooks_callback ]
  
  def show
    respond_to do |format|
      format.json {
        render :json => {
          :user => User.find(params[:id])
        }
      }
    end
  end

  def freshbooks_authorize
    request_token = freshbooks_client.get_request_token(
      oauth_callback: freshbooks_authorize_callback_url)
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

  def dropbox_authorize
    request_token = dropbox_client.get_request_token
    session[:dropbox_token] = request_token.token
    session[:dropbox_secret] = request_token.secret
    redirect_to request_token.authorize_url(
      oauth_callback: dropbox_authorize_callback_url)
  end

  def dropbox_authorize_callback
    access_token = dropbox_client.get_access_token(
      session[:dropbox_token],
      session[:dropbox_secret])

    current_user.update_attributes(
      dropbox_uid: params[:uid],
      dropbox_token: access_token.token,
      dropbox_secret: access_token.secret)

    # go get invoices for this user
    current_user.sync_invoices_async

    redirect_to root_path
  end

  def freshbooks_callback
    case params[:name]
    when "invoice.create", "invoice.update"
      user = User.find_by_freshbooks_user_id(params[:user_id])
      attributes = user.freshbooks_client.get_invoice(params[:object_id])
      invoice = Invoice.new(user, attributes)
      invoice.upload_to_dropbox
    when "invoice.delete"
      user = User.find_by_freshbooks_user_id(params[:user_id])
      attributes = user.freshbooks_client.get_invoice(params[:object_id])
      invoice = Invoice.new(user, attributes)
      invoice.delete_from_dropbox
    end
    render status: :ok, nothing: true
  end

private
  def freshbooks_client
    @freshbooks_client ||= Dropbooks.create_freshbooks_client(freshbooks_account)
  end

  def dropbox_client
    @dropbox_client ||= Dropbooks.create_dropbox_client
  end

  def freshbooks_account
    params[:account] || session[:freshbooks_account]
  end
end
