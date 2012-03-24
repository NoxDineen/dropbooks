# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120324222203) do

  create_table "users", :force => true do |t|
    t.string   "token",                                           :null => false
    t.string   "freshbooks_account"
    t.string   "freshbooks_token"
    t.string   "freshbooks_secret"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "dropbox_uid"
    t.string   "dropbox_token"
    t.string   "dropbox_secret"
    t.string   "status",                   :default => "running"
    t.datetime "last_updated_at"
    t.integer  "total_number_of_invoices", :default => 0
    t.string   "dropbox_name"
  end

end
