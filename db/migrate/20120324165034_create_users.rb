class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :token, null: false
      t.string :freshbooks_account
      t.string :freshbooks_token
      t.string :freshbooks_secret
      t.timestamps
    end
  end
end
