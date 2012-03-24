class AddDropboxNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dropbox_name, :string
  end
end
