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

ActiveRecord::Schema.define(version: 20170731191735) do

  create_table "airplanes", force: :cascade do |t|
    t.string   "model"
    t.string   "engine_class"
    t.integer  "weight"
    t.integer  "height"
    t.integer  "wingspan"
    t.integer  "length"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "manufacturer"
  end

  create_table "airplanes_users", id: false, force: :cascade do |t|
    t.integer "user_id",     null: false
    t.integer "airplane_id", null: false
    t.index ["airplane_id"], name: "index_airplanes_users_on_airplane_id"
    t.index ["user_id"], name: "index_airplanes_users_on_user_id"
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
    t.integer  "minimum"
    t.integer  "maximum"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "classification_id"
    t.index ["classification_id"], name: "index_categories_on_classification_id"
  end

  create_table "cities", force: :cascade do |t|
    t.string   "name"
    t.string   "state"
    t.string   "latitude"
    t.string   "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "airport_id"
    t.integer  "classification_id"
    t.index ["airport_id"], name: "index_fbos_on_airport_id"
    t.index ["classification_id"], name: "index_fbos_on_classification_id"
  end

  create_table "fee_types", force: :cascade do |t|
    t.string   "fee_type_description"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "fees", force: :cascade do |t|
    t.integer  "price"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "fee_type_id"
    t.integer  "fbo_id"
    t.integer  "category_id"
    t.index ["category_id"], name: "index_fees_on_category_id"
    t.index ["fbo_id"], name: "index_fees_on_fbo_id"
    t.index ["fee_type_id"], name: "index_fees_on_fee_type_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
    t.string   "remember_digest"
  end

end
