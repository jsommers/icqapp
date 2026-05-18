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

ActiveRecord::Schema[8.1].define(version: 2026_05_18_214855) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "attendances", force: :cascade do |t|
    t.boolean "active"
    t.integer "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_attendances_on_course_id"
  end

  create_table "attendances_users", id: false, force: :cascade do |t|
    t.integer "attendance_id", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "attendance_id"], name: "index_attendances_users_on_user_id_and_attendance_id", unique: true
  end

  create_table "cold_calls", force: :cascade do |t|
    t.integer "count"
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["course_id"], name: "index_cold_calls_on_course_id"
    t.index ["user_id"], name: "index_cold_calls_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "daytime"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "courses_users", id: false, force: :cascade do |t|
    t.integer "course_id", null: false
    t.integer "user_id", null: false
    t.index ["course_id", "user_id"], name: "index_courses_users_on_course_id_and_user_id"
    t.index ["user_id", "course_id"], name: "index_courses_users_on_user_id_and_course_id"
  end

  create_table "discussion_boards", force: :cascade do |t|
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_discussion_boards_on_course_id"
  end

  create_table "discussion_posts", force: :cascade do |t|
    t.boolean "anonymous", default: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "discussion_board_id", null: false
    t.string "tag", default: "general"
    t.datetime "updated_at", null: false
    t.integer "upvotes", default: 0
    t.integer "user_id", null: false
    t.index ["discussion_board_id"], name: "index_discussion_posts_on_discussion_board_id"
    t.index ["user_id"], name: "index_discussion_posts_on_user_id"
  end

  create_table "discussion_responses", force: :cascade do |t|
    t.boolean "anonymous", default: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "discussion_post_id", null: false
    t.datetime "updated_at", null: false
    t.integer "upvotes", default: 0
    t.integer "user_id", null: false
    t.index ["discussion_post_id"], name: "index_discussion_responses_on_discussion_post_id"
    t.index ["user_id"], name: "index_discussion_responses_on_user_id"
  end

  create_table "discussion_upvotes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "voteable_id", null: false
    t.string "voteable_type", null: false
    t.index ["user_id", "voteable_type", "voteable_id"], name: "idx_upvote_uniqueness", unique: true
    t.index ["user_id"], name: "index_discussion_upvotes_on_user_id"
    t.index ["voteable_type", "voteable_id"], name: "index_discussion_upvotes_on_voteable"
  end

  create_table "poll_responses", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "poll_id"
    t.text "response"
    t.string "type"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["poll_id"], name: "index_poll_responses_on_poll_id"
    t.index ["user_id"], name: "index_poll_responses_on_user_id"
  end

  create_table "polls", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.boolean "isopen"
    t.integer "question_id"
    t.integer "round"
    t.string "type"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["question_id"], name: "index_polls_on_question_id"
  end

  create_table "questions", force: :cascade do |t|
    t.text "answer"
    t.integer "course_id"
    t.datetime "created_at", null: false
    t.text "qname"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_questions_on_course_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false
    t.datetime "created_at", precision: nil, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "uid"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attendances", "courses"
  add_foreign_key "cold_calls", "courses"
  add_foreign_key "cold_calls", "users"
  add_foreign_key "discussion_boards", "courses"
  add_foreign_key "discussion_posts", "discussion_boards"
  add_foreign_key "discussion_posts", "users"
  add_foreign_key "discussion_responses", "discussion_posts"
  add_foreign_key "discussion_responses", "users"
  add_foreign_key "discussion_upvotes", "users"
  add_foreign_key "poll_responses", "polls"
  add_foreign_key "poll_responses", "users"
  add_foreign_key "polls", "questions"
end
