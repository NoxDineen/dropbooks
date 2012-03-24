class Invoice
  attr_reader :user, :attributes

  def initialize(user, attributes)
    @user = user
    @attributes = attributes
  end

  def upload_to_dropbox
    file = File.open(download_from_freshbooks)
    user.dropbox_client(content_host: true).upload(file, "#{attributes[:id]}.pdf", "")
  end

  def download_from_freshbooks(&block)
    # save pdf of invoice /tmp
    pdf_file = Rails.root.join("tmp/#{user.freshbooks_account}_#{attributes[:id]}.pdf")
    File.open(pdf_file, "wb") do |f|
      f.write user.freshbooks_client.get_invoice_pdf(attributes[:id])
    end
    pdf_file
  end
end