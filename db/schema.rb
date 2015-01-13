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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140806161139) do

  create_table "experiments", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "custom_field_1_name"
    t.string   "custom_field_2_name"
    t.string   "custom_field_3_name"
  end

  create_table "messages", force: true do |t|
    t.boolean  "outgoing"
    t.string   "to_number"
    t.string   "from_number"
    t.string   "body"
    t.string   "message_sid"
    t.string   "account_sid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",       default: "unqueued"
    t.integer  "subject_id"
    t.integer  "operation_id"
    t.boolean  "replied",      default: false
    t.boolean  "active",       default: true
  end

  create_table "operations", force: true do |t|
    t.string   "name"
    t.integer  "trigger_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "executed"
    t.string   "kind"
    t.text     "content"
    t.string   "schedule_name"
    t.string   "alert_threshold"
    t.string   "alert_context"
  end

  create_table "operationtypes", force: true do |t|
    t.string   "name"
    t.string   "type"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", force: true do |t|
    t.text     "name"
    t.text     "type"
    t.boolean  "approved",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "default_trigger_time_zone"
  end

  create_table "signups", force: true do |t|
    t.integer  "user_id"
    t.integer  "experiment_id"
    t.integer  "subject_id"
    t.string   "client_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subjects", force: true do |t|
    t.integer  "experiment_id"
    t.string   "email"
    t.string   "phone_number"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "custom_field_1_value"
    t.string   "custom_field_2_value"
    t.string   "custom_field_3_value"
  end

  create_table "triggers", force: true do |t|
    t.integer  "experiment_id"
    t.integer  "start_month"
    t.integer  "start_day"
    t.integer  "start_year"
    t.integer  "hour",                   default: 0
    t.integer  "minute",                 default: 0
    t.boolean  "am",                     default: true
    t.string   "repeat",                 default: "none"
    t.integer  "interval",               default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "trigger_time_zone"
    t.integer  "preceding_operation_id"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "type"
    t.integer  "organization_id"
    t.string   "role"
    t.string   "login",                                 null: false
    t.string   "email",                                 null: false
    t.string   "crypted_password",                      null: false
    t.string   "password_salt",                         null: false
    t.string   "persistence_token",                     null: false
    t.string   "single_access_token",                   null: false
    t.string   "perishable_token",                      null: false
    t.integer  "login_count",               default: 0, null: false
    t.integer  "failed_login_count",        default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "default_trigger_time_zone"
    t.string   "phone_number"
  end

end
