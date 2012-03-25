class User < ActiveRecord::Base
  has_many :invoices, dependent: :destroy

  before_create :set_token
  before_validation :set_freshbooks_user_id, on: :create
  before_validation :set_dropbox_name, if: :dropbox_token_changed?

  validates :dropbox_name, presence: true, if: :dropbox_authorized?
  validates :freshbooks_user_id, presence: true, if: :freshbooks_authorized?

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

  def find_or_create_invoices
    freshbooks_client.get_invoices.collect do |invoice|
      invoice = freshbooks_client.get_invoice(invoice[:id])
      invoices.find_or_create_by_freshbooks_id(invoice[:id], freshbooks_number: invoice[:number])
    end
  end

  def sync_invoices
    find_or_create_invoices
    invoices.each { |invoice| invoice.upload_to_dropbox }
    update_attribute(:status, "finished")
  end

  def sync_invoices_async
    Celluloid::Future.new { User.find(self.id).sync_invoices }
  end

private
  def set_token
    self.token = Dropbooks::Random.friendly_token
  end

  def set_freshbooks_user_id
    user = freshbooks_client.get_current_user
    self.freshbooks_user_id = user[:id] if user
  end

  def set_dropbox_name
    return if dropbox_token.blank?
    account = dropbox_client.account_info
    self.dropbox_name = account["display_name"] if account
  end
end
