# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_06_13_150753) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "booking_requests", force: :cascade do |t|
    t.datetime "from"
    t.datetime "to"
    t.bigint "place_id", null: false
    t.bigint "user_id", null: false
    t.boolean "accepted"
    t.string "note"
    t.bigint "booking_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["booking_id"], name: "index_booking_requests_on_booking_id"
    t.index ["place_id"], name: "index_booking_requests_on_place_id"
    t.index ["user_id"], name: "index_booking_requests_on_user_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.datetime "from"
    t.datetime "to"
    t.boolean "cancelled", default: false, null: false
    t.bigint "place_id", null: false
    t.bigint "user_id", null: false
    t.bigint "approved_by_user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["approved_by_user_id"], name: "index_bookings_on_approved_by_user_id"
    t.index ["place_id"], name: "index_bookings_on_place_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "place_admins", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "place_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["place_id"], name: "index_place_admins_on_place_id"
    t.index ["user_id"], name: "index_place_admins_on_user_id"
  end

  create_table "places", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.boolean "auto_accept", default: false
    t.boolean "enabled", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "access_token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "booking_requests", "bookings"
  add_foreign_key "booking_requests", "places"
  add_foreign_key "booking_requests", "users"
  add_foreign_key "bookings", "places"
  add_foreign_key "bookings", "users"
  add_foreign_key "bookings", "users", column: "approved_by_user_id"
  add_foreign_key "place_admins", "places"
  add_foreign_key "place_admins", "users"
end
