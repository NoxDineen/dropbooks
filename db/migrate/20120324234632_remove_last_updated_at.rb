class RemoveLastUpdatedAt < ActiveRecord::Migration
  def up
    remove_column :users, :last_updated_at
  end

  def down
    add_column :users, :last_updated_at, :datetime
  end
end
