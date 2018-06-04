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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180528153206) do

  create_table "registrations", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phonenumber"
    t.boolean "is_member"
    t.string "contact_person"
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hashedEmail"
    t.boolean "confirmed"
    t.text "shortname"
    t.boolean "german"
    t.boolean "english"
    t.boolean "french"
    t.text "comment"
    t.datetime "start"
    t.datetime "end"
  end

end
