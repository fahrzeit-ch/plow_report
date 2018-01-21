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

ActiveRecord::Schema.define(version: 20180120234220) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.index ["start", "end"], name: "index_drives_on_start_and_end"
  end

  create_table "standby_dates", force: :cascade do |t|
    t.date "day", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day"], name: "index_standby_dates_on_day"
  end

end
