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

ActiveRecord::Schema.define(version: 2022_04_02_115905) do

  create_table "contact_people", force: :cascade do |t|
    t.string "hashed_email"
    t.boolean "confirmed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hashed_email"], name: "index_contact_people_on_hashed_email", unique: true
  end

  create_table "registrations", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phonenumber"
    t.string "is_friend"
    t.string "contact_persons_email"
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hashed_email"
    t.boolean "confirmed"
    t.text "shortname"
    t.string "german"
    t.string "english"
    t.string "french"
    t.text "comment"
    t.string "start"
    t.string "end"
    t.integer "contact_person_id"
    t.boolean "shift_confirmed"
    t.string "is_palapa"
    t.string "is_construction"
    t.string "is_breakdown"
    t.string "did_work"
    t.string "did_orga"
    t.string "wants_orga"
    t.string "has_secu"
    t.string "has_secu_registered"
    t.string "wants_guard"
    t.string "real_forename"
    t.string "real_lastname"
    t.index ["contact_person_id"], name: "index_registrations_on_contact_person_id"
    t.index ["hashed_email"], name: "index_registrations_on_hashed_email", unique: true
  end

end
