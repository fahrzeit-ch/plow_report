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

ActiveRecord::Schema.define(version: 20180627153725) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "administrators", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.string "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.json "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.json "options", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_email", null: false
    t.string "address", default: "", null: false
    t.string "zip_code", default: "", null: false
    t.string "city", default: "", null: false
    t.index ["name"], name: "index_companies_on_name", unique: true
  end

  create_table "company_members", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "company_id"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_members_on_company_id"
    t.index ["user_id", "company_id"], name: "index_company_members_on_user_id_and_company_id", unique: true
    t.index ["user_id"], name: "index_company_members_on_user_id"
  end

  create_table "driver_logins", force: :cascade do |t|
    t.bigint "driver_id"
    t.bigint "user_id"
    t.index ["driver_id", "user_id"], name: "index_driver_logins_on_driver_id_and_user_id", unique: true
    t.index ["driver_id"], name: "index_driver_logins_on_driver_id"
    t.index ["driver_id"], name: "uniq_index_driver_logins_on_driver_id", unique: true
    t.index ["user_id"], name: "index_driver_logins_on_user_id"
  end

  create_table "drivers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "drives", force: :cascade do |t|
    t.datetime "start", null: false
    t.datetime "end", null: false
    t.float "distance_km", default: 0.0, null: false
    t.boolean "salt_refilled", default: false, null: false
    t.float "salt_amount_tonns", default: 0.0, null: false
    t.boolean "salted", default: false, null: false
    t.boolean "plowed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "driver_id", null: false
    t.index ["start", "end"], name: "index_drives_on_start_and_end"
  end

  create_table "recordings", force: :cascade do |t|
    t.datetime "start_time", null: false
    t.bigint "driver_id"
    t.index ["driver_id"], name: "index_recordings_on_driver_id", unique: true
  end

  create_table "standby_dates", force: :cascade do |t|
    t.date "day", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "driver_id", null: false
    t.index ["day"], name: "index_standby_dates_on_day"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: "", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "driver_logins", "drivers"
  add_foreign_key "driver_logins", "users"
  add_foreign_key "drivers", "companies"
  add_foreign_key "drives", "drivers", name: "fk_drives_driver"
  add_foreign_key "standby_dates", "drivers", name: "fk_standby_dates_driver"
end
