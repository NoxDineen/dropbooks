module Dropbooks
  module Random
    def self.friendly_token
      SecureRandom.base64(15).tr("+/=", "-_ ").strip.delete("\n")
    end
  end
end
