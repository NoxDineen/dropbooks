class AddFreshbooksUserIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :freshbooks_user_id, :string

  end
end
