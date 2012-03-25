class Invoice < ActiveRecord::Base
  belongs_to :user

  validates :freshbooks_id, presence: true
  validates :freshbooks_number, presence: true

  def filename
    "#{freshbooks_number}.pdf"
  end

  def upload_to_dropbox
    file = File.open(download_from_freshbooks)
    user.dropbox_client(content_host: true).upload(file, filename, "")
  end

  def delete_from_dropbox
    user.dropbox_client.delete_file("/#{filename}")
  end

  def download_from_freshbooks(&block)
    path = Rails.root.join("tmp", "#{user.freshbooks_account}_#{filename}")
    File.open(path, "wb") do |f|
      f.write user.freshbooks_client.get_invoice_pdf(freshbooks_id)
    end
    path
  end
end