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

  def freshbooks_client
    Dropbooks.create_freshbooks_client(freshbooks_account, freshbooks_token, freshbooks_secret)
  end

  def invoices
    freshbooks_client.get_invoices.collect { |attributes| Invoice.new(self, attributes) }
  end

  def sync_invoices
    invoices.each { |invoice| invoice.upload_to_dropbox }
  end

  def sync_invoices_async
    Celluloid::Future.new { User.find(self.id).sync_invoices }
  end

  def as_json(options = {})
    super(options.merge(:only => [:id, :status]))
  end

private
  def set_token
    self.token = Dropbooks::Random.friendly_token
  end
end
