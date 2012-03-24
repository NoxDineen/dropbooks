class User < ActiveRecord::Base
  before_create :set_token

  def freshbooks_authorized?
    freshbooks_token.present?
  end

  def dropbox_authorized?
    dropbox_token.present?
  end

  def dropbox_client(options={})
    Dropbooks.create_dropbox_client(dropbox_token, dropbox_secret, options)
  end

private
  def set_token
    self.token = Dropbooks::Random.friendly_token
  end
end
