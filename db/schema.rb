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

ActiveRecord::Schema.define(:version => 20151202165743) do

  create_table "accounts", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
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
    t.integer  "country",                               :default => 100
    t.string   "state",                  :limit => 40
    t.string   "city",                   :limit => 40
    t.string   "postal_code",            :limit => 10
    t.float    "latitude"
    t.float    "longitude"
    t.string   "authentication_token"
    t.boolean  "login_allowed"
    t.boolean  "mimics_admin",                          :default => false
    t.string   "phone",                  :limit => 15
    t.string   "mobile"
  end

  add_index "accounts", ["authentication_token"], :name => "index_accounts_on_authentication_token"
  add_index "accounts", ["email"], :name => "index_accounts_on_email", :unique => true
  add_index "accounts", ["reset_password_token"], :name => "index_accounts_on_reset_password_token", :unique => true

  create_table "aggr_by_topics", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "aggregator_id"
    t.string   "aggregator_type", :limit => 20
    t.float    "benchmark"
    t.float    "average"
    t.integer  "attempts"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "attempts", :force => true do |t|
    t.integer  "pupil_id"
    t.integer  "question_id"
    t.boolean  "checked_answer",                 :default => false
    t.integer  "num_attempts",                   :default => 0
    t.boolean  "got_right"
    t.integer  "max_opened",                     :default => 0
    t.integer  "max_time"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.integer  "total_time"
    t.boolean  "seen_summary",                   :default => false
    t.integer  "time_to_answer"
    t.string   "time_on_cards",    :limit => 40
    t.integer  "time_in_activity"
    t.integer  "num_surrender"
  end

  add_index "attempts", ["pupil_id"], :name => "index_koshishein_on_pupil_id"
  add_index "attempts", ["question_id"], :name => "index_koshishein_on_question_id"

  create_table "bundle_questions", :force => true do |t|
    t.integer  "bundle_id"
    t.integer  "question_id"
    t.string   "label",       :limit => 8
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "bundle_questions", ["bundle_id"], :name => "index_bundle_questions_on_bundle_id"

  create_table "bundles", :force => true do |t|
    t.string   "uid",           :limit => 50
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "signature",     :limit => 20
    t.boolean  "auto_download",               :default => false
  end

  create_table "checklists", :force => true do |t|
    t.integer "rubric_id"
    t.integer "criterion_id"
    t.integer "index"
    t.boolean "active",       :default => false
  end

  add_index "checklists", ["criterion_id"], :name => "index_checklists_on_criterion_id"
  add_index "checklists", ["rubric_id"], :name => "index_checklists_on_rubric_id"

  create_table "commentaries", :force => true do |t|
    t.integer "question_id"
    t.integer "tex_comment_id"
  end

  add_index "commentaries", ["question_id"], :name => "index_commentaries_on_question_id"
  add_index "commentaries", ["tex_comment_id"], :name => "index_commentaries_on_tex_comment_id"

  create_table "courses", :force => true do |t|
    t.string   "title",       :limit => 150
    t.text     "description"
    t.integer  "teacher_id"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.boolean  "live",                       :default => true
  end

  add_index "courses", ["teacher_id"], :name => "index_courses_on_teacher_id"

  create_table "criteria", :force => true do |t|
    t.string   "text"
    t.integer  "penalty",                  :default => 0
    t.integer  "account_id"
    t.boolean  "standard",                 :default => true
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.boolean  "red_flag",                 :default => false
    t.boolean  "orange_flag",              :default => false
    t.string   "shortcut",    :limit => 1
  end

  add_index "criteria", ["account_id"], :name => "index_criteria_on_account_id"

  create_table "daily_quizzes", :force => true do |t|
    t.string   "qids"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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

  create_table "devices", :force => true do |t|
    t.integer  "pupil_id"
    t.string   "gcm_token"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "live",       :default => true
  end

  add_index "devices", ["pupil_id"], :name => "index_devices_on_pupil_id"

  create_table "disputes", :force => true do |t|
    t.integer  "student_id"
    t.integer  "tryout_id"
    t.text     "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "disputes", ["student_id"], :name => "index_disputes_on_student_id"

  create_table "doodles", :force => true do |t|
    t.integer  "examiner_id"
    t.integer  "feedback",    :default => 0
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "tryout_id"
  end

  add_index "doodles", ["examiner_id"], :name => "index_doodles_on_examiner_id"

  create_table "doubts", :force => true do |t|
    t.integer  "student_id"
    t.integer  "examiner_id"
    t.string   "scan",        :limit => 30
    t.string   "solution",    :limit => 30
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.boolean  "in_db",                     :default => false
    t.boolean  "refunded",                  :default => false
    t.integer  "price"
  end

  add_index "doubts", ["examiner_id"], :name => "index_doubts_on_examiner_id"
  add_index "doubts", ["student_id"], :name => "index_doubts_on_student_id"

  create_table "examiners", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin",                        :default => false
    t.string   "first_name",        :limit => 30
    t.string   "last_name",         :limit => 30
    t.datetime "last_workset_on"
    t.integer  "n_assigned",                      :default => 0
    t.integer  "n_graded",                        :default => 0
    t.boolean  "live",                            :default => false
    t.integer  "mentor_id"
    t.boolean  "mentor_is_teacher",               :default => false
    t.boolean  "internal",                        :default => false
  end

  add_index "examiners", ["mentor_id"], :name => "index_examiners_on_mentor_id"

  create_table "exams", :force => true do |t|
    t.integer  "quiz_id"
    t.string   "name",        :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "publishable",                :default => false
    t.boolean  "takehome",                   :default => false
    t.integer  "job_id",                     :default => -1
    t.integer  "duration"
    t.datetime "grade_by"
    t.string   "uid",         :limit => 40
    t.boolean  "open",                       :default => true
    t.datetime "submit_by"
    t.datetime "regrade_by"
    t.text     "dist_scheme"
    t.integer  "rubric_id"
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

  create_table "freebies", :force => true do |t|
    t.integer  "course_id"
    t.integer  "lesson_id"
    t.integer  "index",      :default => 0
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "freebies", ["course_id"], :name => "index_freebies_on_course_id"
  add_index "freebies", ["lesson_id"], :name => "index_freebies_on_lesson_id"

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
    t.string   "first_name", :limit => 30
    t.string   "last_name",  :limit => 30
  end

  create_table "hints", :force => true do |t|
    t.text    "text"
    t.integer "index"
    t.integer "subpart_id"
  end

  add_index "hints", ["subpart_id"], :name => "index_hints_on_subpart_id"

  create_table "jokes", :force => true do |t|
    t.string  "uid",       :limit => 20
    t.boolean "image",                   :default => false
    t.integer "num_shown",               :default => 0
    t.boolean "disabled",                :default => false
  end

  create_table "kaagaz", :force => true do |t|
    t.string  "path",    :limit => 40
    t.integer "stab_id"
  end

  add_index "kaagaz", ["stab_id"], :name => "index_kaagaz_on_stab_id"

  create_table "lessons", :force => true do |t|
    t.string   "title",       :limit => 150
    t.text     "description"
    t.integer  "teacher_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "lessons", ["teacher_id"], :name => "index_lessons_on_teacher_id"

  create_table "notif_responses", :force => true do |t|
    t.string  "category",      :limit => 10
    t.string  "uid",           :limit => 20
    t.integer "parent_id"
    t.integer "num_sent",                    :default => 0
    t.integer "num_received",                :default => 0
    t.integer "num_failed",                  :default => 0
    t.integer "num_dismissed",               :default => 0
    t.integer "num_opened",                  :default => 0
  end

  create_table "potd", :force => true do |t|
    t.string  "uid",           :limit => 40
    t.integer "question_id"
    t.integer "num_received",                :default => 0
    t.integer "num_opened",                  :default => 0
    t.integer "num_dismissed",               :default => 0
    t.integer "num_failed",                  :default => 0
    t.integer "num_sent",                    :default => 0
  end

  create_table "pupils", :force => true do |t|
    t.string   "first_name", :limit => 50
    t.string   "last_name",  :limit => 50
    t.string   "email",      :limit => 100
    t.integer  "gender"
    t.string   "birthday",   :limit => 50
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "pupils", ["email"], :name => "index_pupils_on_email"

  create_table "puzzles", :force => true do |t|
    t.text     "text"
    t.integer  "question_id"
    t.integer  "version",        :default => 0
    t.integer  "n_picked",       :default => 0
    t.boolean  "active",         :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.date     "last_picked_on"
  end

  add_index "puzzles", ["question_id"], :name => "index_puzzles_on_question_id"

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
    t.integer  "auditor"
    t.datetime "audited_on"
    t.boolean  "available",                     :default => true
    t.integer  "n_codices",                     :default => 0
    t.string   "codices",         :limit => 5
    t.boolean  "potd",                          :default => false
    t.integer  "num_potd",                      :default => 0
  end

  add_index "questions", ["topic_id"], :name => "index_questions_on_topic_id"

  create_table "quizzes", :force => true do |t|
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_questions"
    t.string   "name",                  :limit => 70
    t.integer  "subject_id"
    t.integer  "total"
    t.integer  "span"
    t.integer  "parent_id"
    t.integer  "job_id",                              :default => -1
    t.string   "uid",                   :limit => 40
    t.string   "version",               :limit => 10
    t.string   "shadows"
    t.string   "page_breaks_after"
    t.string   "switch_versions_after"
  end

  add_index "quizzes", ["parent_id"], :name => "index_quizzes_on_parent_id"
  add_index "quizzes", ["teacher_id"], :name => "index_quizzes_on_teacher_id"

  create_table "remarks", :force => true do |t|
    t.integer  "x"
    t.integer  "y"
    t.integer  "tryout_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "tex_comment_id"
    t.integer  "doodle_id"
    t.integer  "examiner_id"
    t.integer  "kaagaz_id"
  end

  add_index "remarks", ["examiner_id"], :name => "index_remarks_on_examiner_id"
  add_index "remarks", ["kaagaz_id"], :name => "index_remarks_on_stab_id"

  create_table "revisions", :force => true do |t|
    t.integer "question_id"
    t.boolean "latex",       :default => false
    t.boolean "hints",       :default => false
  end

  create_table "rubrics", :force => true do |t|
    t.string   "name",       :limit => 100
    t.integer  "account_id"
    t.boolean  "standard",                  :default => true
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.boolean  "active",                    :default => false
  end

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.string   "phone",      :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "xls"
    t.string   "uid",        :limit => 10
  end

  create_table "sektions", :force => true do |t|
    t.string   "name",                 :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "teacher_id"
    t.string   "uid",                  :limit => 10
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "auto_renew",                         :default => true
    t.boolean  "active"
    t.boolean  "auto_renew_immediate",               :default => false
  end

  create_table "stabs", :force => true do |t|
    t.integer  "student_id"
    t.integer  "examiner_id"
    t.integer  "quality",          :default => -1
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "uid"
    t.integer  "question_id"
    t.integer  "version"
    t.boolean  "puzzle",           :default => true
    t.integer  "answer_deduct",    :default => 0
    t.integer  "solution_deduct",  :default => 0
    t.integer  "proofread_credit", :default => 0
    t.integer  "first_shot"
  end

  add_index "stabs", ["examiner_id"], :name => "index_stabs_on_examiner_id"
  add_index "stabs", ["question_id"], :name => "index_stabs_on_question_id"
  add_index "stabs", ["student_id"], :name => "index_stabs_on_student_id"
  add_index "stabs", ["uid"], :name => "index_stabs_on_uid"

  create_table "student_rosters", :force => true do |t|
    t.integer "student_id"
    t.integer "sektion_id"
  end

  create_table "students", :force => true do |t|
    t.integer  "guardian_id"
    t.string   "first_name",     :limit => 30
    t.string   "last_name",      :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "shell",                        :default => false
    t.string   "phone",          :limit => 15
    t.boolean  "indie"
    t.integer  "reward_gredits",               :default => 100
    t.integer  "paid_gredits",                 :default => 0
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

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], :name => "taggings_idx", :unique => true
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "taggings_count", :default => 0
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "takehomes", :force => true do |t|
    t.integer  "course_id"
    t.integer  "quiz_id"
    t.integer  "index",      :default => 0
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "live",       :default => true
  end

  create_table "teachers", :force => true do |t|
    t.string   "first_name", :limit => 30
    t.string   "last_name",  :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
    t.boolean  "indie",                    :default => true
  end

  create_table "tex_comments", :force => true do |t|
    t.text     "text"
    t.integer  "examiner_id"
    t.boolean  "trivial"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "n_used",      :default => 0
  end

  create_table "topics", :force => true do |t|
    t.string   "name",        :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vertical_id"
  end

  create_table "tryouts", :force => true do |t|
    t.integer  "student_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "examiner_id"
    t.integer  "q_selection_id"
    t.float    "marks"
    t.string   "scan",           :limit => 40
    t.integer  "subpart_id"
    t.integer  "page"
    t.integer  "feedback",                     :default => 0
    t.integer  "worksheet_id"
    t.boolean  "mobile",                       :default => true
    t.boolean  "disputed",                     :default => false
    t.boolean  "resolved",                     :default => false
    t.boolean  "orange_flag"
    t.boolean  "red_flag"
    t.boolean  "weak"
    t.boolean  "medium"
    t.boolean  "strong"
    t.integer  "first_shot"
  end

  add_index "tryouts", ["q_selection_id"], :name => "index_graded_responses_on_q_selection_id"
  add_index "tryouts", ["student_id"], :name => "index_graded_responses_on_student_id"
  add_index "tryouts", ["worksheet_id"], :name => "index_graded_responses_on_worksheet_id"

  create_table "verticals", :force => true do |t|
    t.string   "name",       :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                       :default => false
    t.integer  "watchable_id"
    t.string   "watchable_type", :limit => 20
    t.string   "uid",            :limit => 20
  end

  create_table "watan", :force => true do |t|
    t.string "name",         :limit => 50
    t.string "alpha_2_code"
  end

  create_table "worksheets", :force => true do |t|
    t.integer  "student_id"
    t.integer  "exam_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "marks"
    t.boolean  "graded",                          :default => false
    t.integer  "honest"
    t.boolean  "received",                        :default => false
    t.string   "signature"
    t.string   "uid",               :limit => 40
    t.integer  "job_id",                          :default => -1
    t.boolean  "billed",                          :default => false
    t.boolean  "orange_flag"
    t.boolean  "red_flag"
    t.integer  "num_views_student",               :default => 0
    t.integer  "num_views_teacher",               :default => 0
  end

  add_index "worksheets", ["exam_id"], :name => "index_answer_sheets_on_testpaper_id"
  add_index "worksheets", ["student_id"], :name => "index_answer_sheets_on_student_id"

end
