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

ActiveRecord::Schema[8.0].define(version: 2025_08_08_150000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_audit_logs", force: :cascade do |t|
    t.bigint "admin_id", null: false
    t.string "action"
    t.json "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_admin_audit_logs_on_admin_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "property_id", null: false
    t.date "check_in"
    t.date "check_out"
    t.integer "guests_count"
    t.integer "price_cents"
    t.string "currency"
    t.string "status"
    t.string "payment_status"
    t.text "special_requests"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id", "check_in", "check_out"], name: "index_bookings_on_property_id_and_check_in_and_check_out"
    t.index ["property_id"], name: "index_bookings_on_property_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.string "provider"
    t.string "provider_payment_id"
    t.integer "amount_cents"
    t.string "status"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_payments_on_booking_id"
  end

  create_table "price_overrides", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.date "date"
    t.integer "price_cents"
    t.boolean "is_blackout"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id", "date"], name: "index_price_overrides_on_property_id_and_date", unique: true
    t.index ["property_id"], name: "index_price_overrides_on_property_id"
  end

  create_table "properties", force: :cascade do |t|
    t.string "name"
    t.string "property_type"
    t.text "description"
    t.integer "max_guests"
    t.jsonb "amenities", default: [], null: false
    t.integer "distance_to_airport_minutes"
    t.boolean "pet_friendly"
    t.boolean "eco_friendly"
    t.jsonb "photos", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "role"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "admin_audit_logs", "users", column: "admin_id"
  add_foreign_key "bookings", "properties"
  add_foreign_key "bookings", "users"
  add_foreign_key "payments", "bookings"
  add_foreign_key "price_overrides", "properties"
end
