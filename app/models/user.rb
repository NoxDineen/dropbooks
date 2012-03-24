require 'dropbooks'

class User < ActiveRecord::Base
  before_create :set_token
  after_create :queue_job_to_fetch_initial_invoices

  def freshbooks_authorized?
    freshbooks_token.present?
  end

  def dropbox_authorized?
    dropbox_token.present?
  end

  def save_initial_invoices
    client = Dropbooks.create_freshbooks_client(
      self.freshbooks_account,
      self.freshbooks_token,
      self.freshbooks_secret
    )
    client.get_invoices.each do |invoice|

      # save pdf of invoice /tmp
      pdf_file = Rails.root.join("tmp/#{self.freshbooks_account}_#{invoice[:id]}.pdf")
      File.open(pdf_file, "wb") do |f|
        f.write client.get_invoice_pdf(invoice[:id])
      end

      # send it to Dropbox
      Dropbooks.save_pdf_to_dropbox(pdf_file)
    end
  end

  def queue_job_to_fetch_initial_invoices
    Celluloid::Future.new { User.find(self.id).save_initial_invoices }
  end

private
  def set_token
    self.token = Dropbooks::Random.friendly_token
  end
end
