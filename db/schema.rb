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

ActiveRecord::Schema.define(:version => 20130404083236) do

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
    t.string   "loggable_type",          :limit => 20
    t.boolean  "active",                                :default => true
    t.string   "username",               :limit => 50
    t.boolean  "trial",                                 :default => true
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
    t.integer  "honest"
    t.boolean  "received",     :default => false
    t.boolean  "compiled",     :default => false
  end

  add_index "answer_sheets", ["student_id"], :name => "index_answer_sheets_on_student_id"
  add_index "answer_sheets", ["testpaper_id"], :name => "index_answer_sheets_on_testpaper_id"

  create_table "countries", :force => true do |t|
    t.string "name",         :limit => 50
    t.string "alpha_2_code"
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
    t.integer  "disputed",                      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin",                      :default => false
    t.string   "first_name",      :limit => 30
    t.string   "last_name",       :limit => 30
    t.datetime "last_workset_on"
    t.integer  "n_assigned",                    :default => 0
    t.integer  "n_graded",                      :default => 0
  end

  create_table "faculty_rosters", :force => true do |t|
    t.integer  "sektion_id"
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favourites", :force => true do |t|
    t.integer "teacher_id"
    t.integer "question_id"
  end

  create_table "graded_responses", :force => true do |t|
    t.integer  "student_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "examiner_id"
    t.boolean  "disputed",                     :default => false
    t.integer  "q_selection_id"
    t.float    "system_marks"
    t.integer  "testpaper_id"
    t.string   "scan",           :limit => 40
    t.integer  "subpart_id"
    t.integer  "page"
    t.float    "marks_teacher"
    t.boolean  "closed",                       :default => false
    t.integer  "feedback",                     :default => 0
  end

  add_index "graded_responses", ["q_selection_id"], :name => "index_graded_responses_on_q_selection_id"
  add_index "graded_responses", ["student_id"], :name => "index_graded_responses_on_student_id"
  add_index "graded_responses", ["testpaper_id"], :name => "index_graded_responses_on_testpaper_id"

  create_table "grades", :force => true do |t|
    t.float    "allotment"
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "calibration_id"
  end

  create_table "guardians", :force => true do |t|
    t.boolean  "is_mother"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "q_selections", :force => true do |t|
    t.integer  "quiz_id"
    t.integer  "question_id"
    t.integer  "start_page"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "index"
    t.integer  "end_page"
  end

  add_index "q_selections", ["question_id"], :name => "index_q_selections_on_question_id"
  add_index "q_selections", ["quiz_id"], :name => "index_q_selections_on_quiz_id"

  create_table "questions", :force => true do |t|
    t.string   "uid",             :limit => 20
    t.integer  "n_picked",                      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "examiner_id"
    t.integer  "topic_id"
    t.integer  "suggestion_id"
    t.integer  "difficulty",                    :default => 1
    t.integer  "marks"
    t.float    "length"
    t.integer  "answer_key_span"
    t.integer  "calculation_aid",               :default => 0
    t.boolean  "audited",                       :default => false
    t.integer  "audited_by"
  end

  add_index "questions", ["topic_id"], :name => "index_questions_on_topic_id"

  create_table "quizzes", :force => true do |t|
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_questions"
    t.string   "name",          :limit => 70
    t.integer  "subject_id"
    t.string   "uid",           :limit => 20
    t.integer  "total"
    t.integer  "span"
    t.integer  "parent_id"
  end

  add_index "quizzes", ["parent_id"], :name => "index_quizzes_on_parent_id"
  add_index "quizzes", ["teacher_id"], :name => "index_quizzes_on_teacher_id"

  create_table "requirements", :force => true do |t|
    t.string  "text",       :limit => 100
    t.string  "bottomline", :limit => 20
    t.boolean "honest",                    :default => false
    t.boolean "cogent",                    :default => false
    t.boolean "complete",                  :default => false
    t.boolean "other",                     :default => false
    t.integer "weight",                    :default => -1
    t.integer "posn"
  end

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.string   "zip_code",   :limit => 15
    t.string   "phone",      :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "xls"
    t.integer  "country_id"
    t.string   "uid",        :limit => 10
  end

  create_table "sektions", :force => true do |t|
    t.string   "name",       :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "teacher_id"
    t.string   "uid",        :limit => 10
  end

  create_table "student_rosters", :force => true do |t|
    t.integer "student_id"
    t.integer "sektion_id"
  end

  create_table "students", :force => true do |t|
    t.integer  "guardian_id"
    t.string   "first_name",  :limit => 30
    t.string   "last_name",   :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uid",         :limit => 20
  end

  create_table "subjects", :force => true do |t|
    t.string   "name",       :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subparts", :force => true do |t|
    t.integer "question_id"
    t.boolean "mcq",           :default => false
    t.boolean "half_page",     :default => false
    t.boolean "full_page",     :default => true
    t.integer "marks"
    t.integer "index"
    t.integer "relative_page"
    t.boolean "few_lines",     :default => false
  end

  add_index "subparts", ["question_id"], :name => "index_subparts_on_question_id"

  create_table "suggestions", :force => true do |t|
    t.integer  "teacher_id"
    t.integer  "examiner_id"
    t.boolean  "completed",                 :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "signature",   :limit => 15
    t.integer  "pages",                     :default => 1
  end

  create_table "teachers", :force => true do |t|
    t.string   "first_name", :limit => 30
    t.string   "last_name",  :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
    t.integer  "country_id"
    t.string   "zip_code",   :limit => 10
  end

  create_table "testpapers", :force => true do |t|
    t.integer  "quiz_id"
    t.string   "name",        :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "publishable",                :default => false
    t.boolean  "exclusive",                  :default => true
    t.boolean  "inboxed",                    :default => false
  end

  create_table "topics", :force => true do |t|
    t.string   "name",        :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vertical_id"
  end

  create_table "trial_accounts", :force => true do |t|
    t.integer  "teacher_id"
    t.string   "school"
    t.string   "zip_code",   :limit => 30
    t.integer  "country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "verticals", :force => true do |t|
    t.string   "name",       :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", :force => true do |t|
    t.text     "url"
    t.boolean  "restricted",                  :default => true
    t.boolean  "instructional",               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",         :limit => 70
    t.boolean  "active",                      :default => false
    t.integer  "index",                       :default => -1
  end

end
