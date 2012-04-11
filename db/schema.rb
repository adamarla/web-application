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

ActiveRecord::Schema.define(:version => 20120411235407) do

  create_table "accounts", :force => true do |t|
    t.string   "email",                                 :default => "",   :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",   :null => false
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
    t.boolean  "active",                                :default => true
    t.string   "username"
  end

  add_index "accounts", ["email"], :name => "index_accounts_on_email", :unique => true
  add_index "accounts", ["reset_password_token"], :name => "index_accounts_on_reset_password_token", :unique => true

  create_table "answer_sheets", :force => true do |t|
    t.integer  "student_id"
    t.integer  "testpaper_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "marks"
    t.boolean  "graded",       :default => false
  end

  create_table "boards", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.integer  "board_id"
    t.integer  "klass"
    t.integer  "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     :default => true
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "examiners", :force => true do |t|
    t.integer  "num_contested",   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin",        :default => false
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "last_workset_on"
  end

  create_table "faculty_rosters", :force => true do |t|
    t.integer  "sektion_id"
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "graded_responses", :force => true do |t|
    t.integer  "student_id"
    t.integer  "grade_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "examiner_id"
    t.boolean  "contested",      :default => false
    t.integer  "q_selection_id"
    t.float    "marks"
    t.integer  "testpaper_id"
    t.string   "scan"
  end

  create_table "grades", :force => true do |t|
    t.integer  "allotment"
    t.integer  "yardstick_id"
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
    t.integer  "index"
  end

  create_table "questions", :force => true do |t|
    t.string   "uid"
    t.integer  "attempts",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "examiner_id"
    t.integer  "topic_id"
    t.integer  "teacher_id"
    t.boolean  "multi_part",    :default => false
    t.integer  "num_parts"
    t.integer  "difficulty",    :default => 1
    t.integer  "marks"
    t.boolean  "mcq",           :default => false
    t.boolean  "multi_correct", :default => false
    t.boolean  "half_page",     :default => false
    t.boolean  "full_page",     :default => true
  end

  create_table "quizzes", :force => true do |t|
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_questions"
    t.string   "name"
    t.integer  "klass"
    t.integer  "subject_id"
    t.integer  "atm_key"
    t.integer  "total"
  end

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tag"
    t.integer  "board_id"
  end

  create_table "sektions", :force => true do |t|
    t.integer  "school_id"
    t.integer  "klass"
    t.string   "section"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "specializations", :force => true do |t|
    t.integer  "teacher_id"
    t.integer  "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "students", :force => true do |t|
    t.integer  "guardian_id"
    t.integer  "school_id"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sektion_id"
  end

  create_table "subjects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subparts", :force => true do |t|
    t.integer "question_id"
    t.boolean "mcq",            :default => false
    t.boolean "half_page",      :default => false
    t.boolean "full_page",      :default => true
    t.integer "marks"
    t.boolean "multi_correct",  :default => false
    t.integer "relative_index"
    t.integer "relative_pg"
  end

  create_table "syllabi", :force => true do |t|
    t.integer  "course_id"
    t.integer  "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "difficulty", :default => 1
  end

  create_table "teachers", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
  end

  create_table "testpapers", :force => true do |t|
    t.integer  "quiz_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vertical_id"
  end

  create_table "verticals", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "yardsticks", :force => true do |t|
    t.string   "example"
    t.integer  "default_allotment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "mcq",               :default => false
    t.string   "annotation"
    t.string   "meaning"
    t.integer  "colour"
  end

end
