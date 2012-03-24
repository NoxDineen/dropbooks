require "freshbooks_client"

module Dropbooks
  module Random
    def self.friendly_token
      SecureRandom.base64(15).tr("+/=", "-_ ").strip.delete("\n")
    end
  end

  def self.freshbooks_oauth_key
    ENV["FRESHBOOKS_KEY"]
  end

  def self.freshbooks_oauth_secret
    ENV["FRESHBOOKS_SECRET"]
  end

  def self.create_freshbooks_client(account, token="", secret="")
    FreshbooksClient.new(self.freshbooks_oauth_key, self.freshbooks_oauth_secret, account, token, secret)
  end
end
