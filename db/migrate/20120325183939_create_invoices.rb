class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.references :user
      t.string :freshbooks_number
      t.string :freshbooks_id
      t.timestamps
    end
  end
end
