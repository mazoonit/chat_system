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

ActiveRecord::Schema[7.1].define(version: 2024_06_08_214048) do
  create_table "applications", force: :cascade, options:“ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci” do |t|
    t.binary "token", limit: 16, null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "chats_count", default: 0
    t.index ["token"], name: "application_token_index", unique: true
  end

  create_table "chats", force: :cascade, options:“ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci” do |t|
    t.integer "number", null: false
    t.integer "application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "messages_count", default: 0
    t.index ["application_id", "number"], name: "application_id_and_chat_number_index"
  end

  create_table "messages", force: :cascade, options:“ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci” do |t|
    t.integer "number", null: false
    t.integer "chat_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id", "number"], name: "chat_id_and_message_number_index"
  end

end
