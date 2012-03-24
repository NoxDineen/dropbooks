class Invoice
  attr_reader :user, :attributes

  def initialize(user, attributes)
    @user = user
    @attributes = attributes
  end

  def filename
    "#{attributes[:number]}.pdf"
  end

  def upload_to_dropbox
    file = File.open(download_from_freshbooks)
    user.dropbox_client(content_host: true).upload(file, "/#{filename}", "")
  end

  def delete_from_dropbox
    user.dropbox_client.delete_file("/#{filename}")
  end

  def download_from_freshbooks(&block)
    path = Rails.root.join("tmp/#{user.freshbooks_account}_#{filename}")
    File.open(path, "wb") do |f|
      f.write user.freshbooks_client.get_invoice_pdf(attributes[:id])
    end
    path
  end
end