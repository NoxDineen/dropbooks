class User < ActiveRecord::Base
  before_create :set_token

private
  def set_token
    self.token = Dropbooks::Random.friendly_token
  end
end
