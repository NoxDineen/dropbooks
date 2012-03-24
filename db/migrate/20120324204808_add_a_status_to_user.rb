class AddAStatusToUser < ActiveRecord::Migration
  def change
    add_column :users, :status, :string, :default => "running"
  end
end
