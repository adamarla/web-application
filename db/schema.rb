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

ActiveRecord::Schema.define(:version => 20170825031859) do

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

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "sku_id"
    t.integer  "got_right"
    t.integer  "date"
    t.integer  "num_attempts"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "activities", ["date"], :name => "index_activities_on_date"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

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
    t.integer  "user_id"
    t.integer  "question_id"
    t.boolean  "checked_answer",               :default => false
    t.integer  "num_attempts",                 :default => 0
    t.boolean  "got_right"
    t.integer  "max_opened",                   :default => 0
    t.integer  "max_time"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.integer  "total_time"
    t.boolean  "seen_summary",                 :default => false
    t.integer  "time_to_answer"
    t.string   "time_on_cards",  :limit => 40
    t.integer  "num_surrender"
    t.integer  "time_to_bingo",                :default => 0
  end

  add_index "attempts", ["question_id"], :name => "index_koshishein_on_question_id"
  add_index "attempts", ["user_id"], :name => "index_koshishein_on_pupil_id"

  create_table "authors", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin",                 :default => false
    t.string   "first_name", :limit => 30
    t.string   "last_name",  :limit => 30
    t.boolean  "live",                     :default => false
    t.string   "email"
  end

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

  create_table "chapters", :force => true do |t|
    t.string  "name",        :limit => 70
    t.integer "grade_id"
    t.integer "subject_id"
    t.string  "uid",         :limit => 10
    t.integer "language_id",               :default => 1
    t.integer "parent_id",                 :default => 0
    t.integer "friend_id",                 :default => 0
  end

  add_index "chapters", ["grade_id"], :name => "index_chapters_on_level_id"
  add_index "chapters", ["subject_id"], :name => "index_chapters_on_subject_id"

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
    t.integer  "user_id"
    t.string   "gcm_token"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "live",       :default => true
  end

  add_index "devices", ["user_id"], :name => "index_devices_on_pupil_id"

  create_table "difficulties", :force => true do |t|
    t.string  "name",    :limit => 10
    t.string  "meaning", :limit => 40
    t.integer "level"
  end

  create_table "expertise", :force => true do |t|
    t.integer "user_id"
    t.integer "skill_id"
    t.integer "num_tested",       :default => 0
    t.integer "num_correct",      :default => 0
    t.float   "weighted_tested",  :default => 0.0
    t.float   "weighted_correct", :default => 0.0
  end

  add_index "expertise", ["skill_id"], :name => "index_expertise_on_skill_id"
  add_index "expertise", ["user_id"], :name => "index_expertise_on_pupil_id"

  create_table "grades", :force => true do |t|
    t.string "name", :limit => 30
  end

  create_table "inventory", :force => true do |t|
    t.integer "zip_id"
    t.integer "sku_id"
  end

  add_index "inventory", ["sku_id"], :name => "index_inventory_on_sku_id"
  add_index "inventory", ["zip_id"], :name => "index_inventory_on_zip_id"

  create_table "jokes", :force => true do |t|
    t.string  "uid",       :limit => 20
    t.boolean "image",                   :default => false
    t.integer "num_shown",               :default => 0
    t.boolean "disabled",                :default => false
  end

  create_table "languages", :force => true do |t|
    t.string "name", :limit => 30
  end

  create_table "parcels", :force => true do |t|
    t.string   "name",           :limit => 50
    t.integer  "chapter_id"
    t.integer  "language_id",                  :default => 1
    t.integer  "min_difficulty"
    t.integer  "max_difficulty"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "contains",       :limit => 20
    t.integer  "max_zip_size"
    t.integer  "skill_id",                     :default => 0
    t.boolean  "open",                         :default => true
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

  create_table "riddles", :force => true do |t|
    t.string   "type",             :limit => 50
    t.integer  "original_id"
    t.integer  "chapter_id"
    t.integer  "parent_riddle_id"
    t.integer  "language_id",                    :default => 1
    t.integer  "difficulty",                     :default => 20
    t.integer  "num_attempted",                  :default => 0
    t.integer  "num_completed",                  :default => 0
    t.integer  "num_correct",                    :default => 0
    t.integer  "author_id"
    t.boolean  "has_svgs",                       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "riddles", ["chapter_id"], :name => "index_riddles_on_chapter_id"
  add_index "riddles", ["language_id"], :name => "index_riddles_on_language_id"

  create_table "skills", :force => true do |t|
    t.integer "chapter_id"
    t.boolean "generic",                       :default => false
    t.string  "uid",             :limit => 15
    t.integer "author_id"
    t.float   "avg_proficiency",               :default => 0.0
    t.integer "language_id",                   :default => 1
    t.boolean "has_svgs",                      :default => false
    t.integer "parent_skill_id"
  end

  create_table "skus", :force => true do |t|
    t.string  "stockable_type"
    t.integer "stockable_id"
    t.string  "path"
    t.boolean "has_draft",      :default => false
    t.integer "num_eps",        :default => 0
  end

  add_index "skus", ["stockable_id"], :name => "index_skus_on_stockable_id"

  create_table "snippets", :force => true do |t|
    t.integer "examiner_id"
    t.integer "num_attempted", :default => 0
    t.integer "num_correct",   :default => 0
    t.integer "chapter_id"
  end

  add_index "snippets", ["chapter_id"], :name => "index_snippets_on_chapter_id"
  add_index "snippets", ["examiner_id"], :name => "index_snippets_on_examiner_id"

  create_table "subjects", :force => true do |t|
    t.string   "name",       :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "usages", :force => true do |t|
    t.integer "user_id"
    t.integer "time_on_snippets",      :default => 0
    t.integer "time_on_questions",     :default => 0
    t.integer "num_snippets_done",     :default => 0
    t.integer "num_questions_done",    :default => 0
    t.integer "time_on_stats",         :default => 0
    t.integer "num_snippets_clicked",  :default => 0
    t.integer "num_questions_clicked", :default => 0
    t.integer "num_dropped",           :default => 0
    t.integer "date",                  :default => 0
    t.integer "num_stats_loaded",      :default => 0
  end

  add_index "usages", ["date"], :name => "index_usages_on_date"
  add_index "usages", ["user_id"], :name => "index_usages_on_user_id"

  create_table "users", :id => false, :force => true do |t|
    t.integer  "id",                                               :null => false
    t.string   "first_name",       :limit => 50
    t.string   "last_name",        :limit => 50
    t.string   "email",            :limit => 100
    t.integer  "gender"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.integer  "num_invites_sent",                :default => 0
    t.integer  "birthday",                        :default => 0
    t.float    "version",                         :default => 1.0
    t.string   "time_zone",        :limit => 50
    t.integer  "join_date"
    t.string   "phone",            :limit => 20
  end

  add_index "users", ["email"], :name => "index_pupils_on_email"

  create_table "wtps", :force => true do |t|
    t.integer "user_id"
    t.integer "price_per_month"
    t.boolean "agreed",          :default => false
    t.integer "num_refusals",    :default => 0
    t.integer "first_asked_on",  :default => 0
    t.integer "agreed_on",       :default => 0
  end

  create_table "zips", :force => true do |t|
    t.string  "name",      :limit => 50
    t.integer "parcel_id"
    t.integer "max_size"
    t.boolean "open",                    :default => true
    t.string  "shasum",    :limit => 10
    t.boolean "modified",                :default => false
  end

  add_index "zips", ["parcel_id"], :name => "index_zips_on_parcel_id"

end
