class AddExtraInformationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_updated_at, :datetime
    add_column :users, :total_number_of_invoices, :integer, :default => 0
  end
end
