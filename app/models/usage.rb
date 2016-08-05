# == Schema Information
#
# Table name: usages
#
#  id                    :integer         not null, primary key
#  date                  :string(30)
#  user_id               :integer
#  time_zone             :string(50)
#  time_on_snippets      :integer         default(0)
#  time_on_questions     :integer         default(0)
#  num_snippets_done     :integer         default(0)
#  num_questions_done    :integer         default(0)
#  time_on_stats         :integer         default(0)
#  num_snippets_clicked  :integer         default(0)
#  num_questions_clicked :integer         default(0)
#  num_dropped           :integer         default(0)
#

class Usage < ActiveRecord::Base
  # attr_accessible :title, :body
  
  validates :date, presence: true 
  validates :date, uniqueness: { scope: :user_id } 

  def num_skipped 
    return (num_questions_clicked - num_questions_done - num_dropped)
  end 

  def self.newcomers
    where('user_id > ?', 537).order(:id)
  end 

  def self.something_done 
    self.newcomers.where('num_snippets_done > ? OR num_questions_done > ?', 0,0)
  end 

  def self.something_clicked
    self.newcomers.where('num_snippets_clicked > ? OR num_questions_clicked > ?', 0,0)
  end 

  def self.some_time_spent
    self.newcomers.where('time_on_snippets > ? OR time_on_questions > ? OR time_on_stats > ?', 0,0,0)
  end 

end
