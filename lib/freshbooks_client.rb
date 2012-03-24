require "oauth/signature/plaintext"
require 'builder'
require 'nokogiri'

class FreshbooksClient
  class APIError < StandardError; end

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

  def get_current_staff
    response = parse_response(request("staff.current"))
    { id: response.css("staff_id").text }
  end

  def get_invoices
    response = parse_response(request("invoice.list"))
    response.css("invoice").map do |invoice|
      { id: invoice.css("invoice_id").text }
    end
  end

  def get_invoice(id)
    response = parse_response(request("invoice.get", invoice_id: id))
    response.css("invoice").map do |invoice|
      { id: invoice.css("invoice_id").text,
        number: invoice.css("number").text }
    end
  end

  def get_invoice_pdf(id)
    response = request("invoice.getPDF", invoice_id: id)
    parse_response(response)
    response
  end

private
  def request(method, params={})
    response = access_token.post(api_endpoint, build_xml(method, params))
    raise APIError, "#{response.code}: #{response.body}" unless response.code == "200"
    response.body
  end

  def parse_response(response)
    response = Nokogiri.parse(response).css("response")
    return if response.empty? # the response might not be xml
    status, error = response.attr("status").text, response.css("error").text
    raise APIError, error unless status == "ok"
    response
  end

  def build_xml(method, params={})
    xml = Builder::XmlMarkup.new
    xml.request("method" => method) do |xml|
      params.each { |key, value| xml.tag!(key, value) }
    end
  end

  def api_endpoint
    "https://#{account}.freshbooks.com/api/2.1/xml-in"
  end
end
