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

ActiveRecord::Schema.define(version: 20171104005343) do

  create_table "airplane_users", force: :cascade do |t|
    t.integer "airplane_id",  null: false
    t.integer "user_id",      null: false
    t.string  "tailnumber"
    t.boolean "user_can_see"
    t.index ["airplane_id", "user_id"], name: "index_airplane_users_on_airplane_id_and_user_id"
  end

  create_table "airplanes", force: :cascade do |t|
    t.string   "model"
    t.string   "engine_class"
    t.integer  "weight"
    t.integer  "height"
    t.integer  "wingspan"
    t.integer  "length"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "manufacturer"
    t.string   "country"
    t.string   "plane_class"
    t.integer  "empty_weight"
    t.integer  "num_crew"
    t.integer  "num_passengers"
    t.integer  "range"
    t.integer  "wing_area"
  end

  create_table "airports", force: :cascade do |t|
    t.string   "airport_code"
    t.string   "name"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "state"
    t.string   "ownerPhone"
    t.string   "managerPhone"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "city_id"
    t.index ["city_id"], name: "index_airports_on_city_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string   "category_description"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "cities", force: :cascade do |t|
    t.string   "name"
    t.string   "state"
    t.string   "latitude"
    t.string   "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "zip"
  end

  create_table "classifications", force: :cascade do |t|
    t.string   "classification_description"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "fbos", force: :cascade do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "alternate_phone"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "airport_id"
    t.string   "email"
    t.string   "hash_id"
    t.index ["airport_id"], name: "index_fbos_on_airport_id"
  end

  create_table "fee_types", force: :cascade do |t|
    t.string   "fee_type_description"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "fees", force: :cascade do |t|
    t.decimal  "price",             precision: 11, scale: 2
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "fee_type_id"
    t.integer  "fbo_id"
    t.integer  "category_id"
    t.string   "time_unit"
    t.decimal  "unit_price",        precision: 11, scale: 2
    t.integer  "unit_magnitude"
    t.string   "free_time_unit"
    t.integer  "free_time_length"
    t.integer  "unit_minimum"
    t.decimal  "time_price",        precision: 11, scale: 2
    t.integer  "unit_maximum"
    t.integer  "start_time"
    t.integer  "end_time"
    t.boolean  "is_estimate"
    t.string   "unit_type"
    t.integer  "classification_id"
    t.index ["category_id"], name: "index_fees_on_category_id"
    t.index ["classification_id"], name: "index_fees_on_classification_id"
    t.index ["fbo_id"], name: "index_fees_on_fbo_id"
    t.index ["fee_type_id"], name: "index_fees_on_fee_type_id"
  end

  create_table "logins", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "logout"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_logins_on_user_id"
  end

  create_table "plan_trips", force: :cascade do |t|
    t.string   "state"
    t.integer  "distance"
    t.integer  "nights"
    t.string   "filter"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.datetime "arrival_time"
    t.datetime "depart_time"
    t.integer  "airplane_user_id"
    t.integer  "city_id"
    t.index ["airplane_user_id"], name: "index_plan_trips_on_airplane_user_id"
    t.index ["city_id"], name: "index_plan_trips_on_city_id"
  end

  create_table "reports", force: :cascade do |t|
    t.integer  "trip_id"
    t.integer  "trip_rating"
    t.string   "trip_comments"
    t.integer  "fbo_rating"
    t.string   "fbo_comments"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "status"
    t.index ["trip_id"], name: "index_reports_on_trip_id"
  end

  create_table "requests", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "sent"
  end

  create_table "trips", force: :cascade do |t|
    t.datetime "arrival_time"
    t.integer  "fbo_id"
    t.integer  "cost"
    t.string   "trip_status"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "issue"
    t.string   "detail"
    t.integer  "airplane_user_id"
    t.datetime "depart_time"
    t.index ["airplane_user_id"], name: "index_trips_on_airplane_user_id"
    t.index ["fbo_id"], name: "index_trips_on_fbo_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.string   "privilege_level"
    t.string   "account_type"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

end
