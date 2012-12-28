class SetStringLimits < ActiveRecord::Migration
  def up
    change_column :subjects, :name, :string, :limit => 30
    change_column :accounts, :loggable_type, :string, :limit => 20
    change_column :accounts, :username, :string, :limit => 50
    change_column :boards, :name, :string, :limit => 50 
    change_column :countries, :name, :string, :limit => 50 
    change_column :courses, :name, :string, :limit => 50
    change_column :examiners, :first_name, :string, :limit => 30
    change_column :examiners, :last_name, :string, :limit => 30
    change_column :graded_responses, :scan, :string, :limit => 40
    change_column :questions, :uid, :string, :limit => 20
    change_column :quizzes, :name, :string, :limit => 70
    change_column :quizzes, :atm_key, :string, :limit => 20
    change_column :schools, :city, :string, :limit => 40
    change_column :schools, :state , :string, :limit => 40
    change_column :schools, :zip_code, :string, :limit => 15 
    change_column :schools, :phone, :string, :limit => 20
    change_column :schools, :tag, :string, :limit => 40
    change_column :sektions, :name, :string, :limit => 40
    change_column :students, :first_name, :string, :limit => 30
    change_column :students, :last_name, :string, :limit => 30
    change_column :subjects, :name, :string, :limit => 30
    change_column :suggestions, :signature, :string, :limit => 15
    change_column :teachers, :first_name, :string, :limit => 30
    change_column :teachers, :last_name, :string, :limit => 30
    change_column :testpapers, :name, :string, :limit => 100
    change_column :topics, :name, :string, :limit => 50
    change_column :trial_accounts, :zip_code, :string, :limit => 30
    change_column :verticals, :name, :string, :limit => 30
    change_column :videos, :title, :string, :limit => 70
  end

  def down
    change_column :subjects, :name, :string, :limit => 255
    change_column :accounts, :loggable_type, :string, :limit => 255
    change_column :accounts, :username, :string, :limit => 255
    change_column :boards, :name, :string, :limit => 255
    change_column :countries, :name, :string, :limit => 255
    change_column :courses, :name, :string, :limit => 255
    change_column :examiners, :first_name, :string, :limit => 255
    change_column :examiners, :last_name, :string, :limit => 255
    change_column :graded_responses, :scan, :string, :limit => 255
    change_column :questions, :uid, :string, :limit => 255
    change_column :quizzes, :name, :string, :limit => 255
    change_column :quizzes, :atm_key, :string, :limit => 255
    change_column :schools, :city, :string, :limit => 255
    change_column :schools, :state , :string, :limit => 255
    change_column :schools, :zip_code, :string, :limit => 255
    change_column :schools, :phone, :string, :limit => 255
    change_column :schools, :tag, :string, :limit => 255
    change_column :sektions, :name, :string, :limit => 255
    change_column :students, :first_name, :string, :limit => 255
    change_column :students, :last_name, :string, :limit => 255
    change_column :subjects, :name, :string, :limit => 255
    change_column :suggestions, :signature, :string, :limit => 255
    change_column :teachers, :first_name, :string, :limit => 255
    change_column :teachers, :last_name, :string, :limit => 255
    change_column :testpapers, :name, :string, :limit => 255
    change_column :topics, :name, :string, :limit => 255
    change_column :trial_accounts, :zip_code, :string, :limit => 255
    change_column :verticals, :name, :string, :limit => 255
    change_column :videos, :title, :string, :limit => 255
  end
end
