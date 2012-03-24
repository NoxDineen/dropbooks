require "net/http/post/multipart"

class DropboxClient
  class APIError < StandardError; end

  attr_accessor :consumer, :access_token

  def initialize(consumer_key, consumer_secret, token="", secret="", options={})
    @consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {
      site: options[:content_host] ? "http://api-content.dropbox.com" : "https://api.dropbox.com",
      scheme: :header,
      http_method: :post,
      request_token_url: "https://api.dropbox.com/1/oauth/request_token",
      access_token_url: "https://api.dropbox.com/1/oauth/access_token",
      authorize_url: "https://www.dropbox.com/1/oauth/authorize"
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

  def account_info
    get("https://api.dropbox.com/1/account/info")
  end

  def get_file(path)
    get("https://api-content.dropbox.com/1/files/sandbox#{escape_path(path)}")
  end

  def upload(file, name, path)
    url = URI.parse("http://api-content.dropbox.com/1/files/sandbox#{escape_path(path)}")

    oauth_request = Net::HTTP::Post.new(url.path)
    oauth_request.set_form_data({ "file" => name })
    consumer.sign!(oauth_request, access_token)
    oauth_sig = oauth_request.to_hash["authorization"]

    request = Net::HTTP::Post::Multipart.new(url.path,
      "file" => UploadIO.new(file, "application/octet-stream", name))
    request["authorization"] = oauth_sig.join(", ")

    Net::HTTP.start(url.host, url.port) do |http|
      parse_response(http.request(request))
    end
  end

  def delete_file(path)
    @access_token.post("https://api.dropbox.com/1/fileops/delete", {
      "root" => "sandbox",
      "path" => path
    })
  end

private
  def get(path)
    parse_response(access_token.get(path))
  end

  def parse_response(response)
    if response.code == "200"
      JSON.parse(response.body)
    else
      raise APIError, response.body
    end
  end

  def escape_path(path)
    path.split("\/").map{|part| escape(part) }.join("\/")
  end

  def escape(value)
    URI::escape(value.to_s, /[^a-zA-Z0-9\-\.\_\~]/)
  end
end