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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111119224156) do

  create_table "accounts", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "loggable_id"
    t.string   "loggable_type"
  end

  add_index "accounts", ["email"], :name => "index_accounts_on_email", :unique => true
  add_index "accounts", ["reset_password_token"], :name => "index_accounts_on_reset_password_token", :unique => true

  create_table "boards", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "broad_topics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.integer  "board_id"
    t.integer  "grade"
    t.integer  "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "examiners", :force => true do |t|
    t.integer  "num_contested", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "secret_key"
    t.boolean  "is_admin",      :default => false
  end

  create_table "faculty_rosters", :force => true do |t|
    t.integer  "study_group_id"
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grade_descriptions", :force => true do |t|
    t.string   "annotation"
    t.string   "description"
    t.integer  "default_allotment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "mcq",               :default => false
    t.boolean  "subpart",           :default => false
  end

  create_table "graded_responses", :force => true do |t|
    t.integer  "quiz_id"
    t.integer  "question_id"
    t.integer  "student_id"
    t.integer  "index_in_quiz"
    t.integer  "on_page"
    t.integer  "grade_id"
    t.string   "scanned_image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "examiner_id"
    t.boolean  "contested",     :default => false
  end

  create_table "grades", :force => true do |t|
    t.integer  "allotment"
    t.integer  "grade_description_id"
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "guardians", :force => true do |t|
    t.boolean  "is_mother"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "q_selections", :force => true do |t|
    t.integer  "quiz_id"
    t.integer  "question_id"
    t.integer  "page"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", :force => true do |t|
    t.string   "path"
    t.integer  "attempts",          :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "examiner_id"
    t.integer  "specific_topic_id"
    t.integer  "teacher_id"
    t.boolean  "mcq",               :default => false
    t.boolean  "multi_correct",     :default => false
    t.boolean  "multi_part",        :default => false
    t.integer  "num_parts"
    t.integer  "difficulty",        :default => 0
  end

  create_table "quizzes", :force => true do |t|
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uid"
    t.integer  "num_students"
    t.integer  "num_questions"
  end

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.integer  "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "specific_topics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "broad_topic_id"
  end

  create_table "students", :force => true do |t|
    t.integer  "guardian_id"
    t.integer  "school_id"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "study_group_id"
  end

  create_table "study_groups", :force => true do |t|
    t.integer  "school_id"
    t.integer  "grade"
    t.string   "section"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subjects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "syllabi", :force => true do |t|
    t.integer  "course_id"
    t.integer  "specific_topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "difficulty",        :default => 0
  end

  create_table "teachers", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
  end

end
