class DropboxClient
  attr_accessor :consumer, :access_token

  def initialize(consumer_key, consumer_secret, token="", secret="")
    @consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {
      :request_token_url => "https://api.dropbox.com/1/oauth/request_token",
      :access_token_url  => "https://api.dropbox.com/1/oauth/access_token",
      :authorize_url     => "https://www.dropbox.com/1/oauth/authorize"
    })
    @access_token = OAuth::AccessToken.new(@consumer, token, secret) if token.present? and secret.present?
  end

  def get_request_token
    @consumer.get_request_token
  end

  def get_access_token(token, secret)
    request_token = OAuth::RequestToken.new(@consumer, token, secret)
    @access_token = request_token.get_access_token
  end
end