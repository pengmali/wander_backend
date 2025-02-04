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

ActiveRecord::Schema[8.0].define(version: 2025_02_04_091626) do
  create_table "costs", force: :cascade do |t|
    t.integer "trip_id", null: false
    t.integer "category", default: 4, null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_costs_on_trip_id"
  end

  create_table "places", force: :cascade do |t|
    t.integer "trip_id", null: false
    t.string "name", null: false
    t.string "category", null: false
    t.string "formatted_address", null: false
    t.float "latitude"
    t.float "longitude"
    t.decimal "cost", precision: 10, scale: 2, default: "0.0"
    t.float "rating"
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_places_on_trip_id"
  end

  create_table "trips", force: :cascade do |t|
    t.integer "user_id"
    t.string "name", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "trip_length", default: 7, null: false
    t.decimal "budget", precision: 10, scale: 2
    t.decimal "total_cost", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_guest_trip"
    t.index ["user_id"], name: "index_trips_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.integer "travel_style", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "costs", "trips"
  add_foreign_key "places", "trips"
  add_foreign_key "trips", "users"
end
