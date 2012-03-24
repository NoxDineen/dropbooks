require "oauth/signature/plaintext"

class FreshbooksClient
  attr_reader :consumer, :access_token, :account

  def initialize(consumer_key, consumer_secret, account, token="", secret="")
    @account = account

    # create the consumer
    @consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {
      site: "https://#{account}.freshbooks.com",
      request_token_path: "/oauth/oauth_request.php",
      access_token_path: "/oauth/oauth_access.php",
      authorize_path: "/oauth/oauth_authorize.php",
      http_method: :post,
      scheme: :query_string,
      signature_method: "PLAINTEXT"
    })

    # create the access token if possible
    @access_token = OAuth::AccessToken.new(@consumer, token, secret) if token.present? and secret.present?
  end

  def get_request_token(options={})
    consumer.get_request_token(options)
  end

  def get_access_token(token, secret, oauth_verifier)
    request_token = OAuth::RequestToken.new(consumer, token, secret)
    @access_token = request_token.get_access_token(oauth_verifier: oauth_verifier)
  end
end