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

  def self.on_app_version(min_version = 1) 
    return self.newcomers if (min_version < 2) 
    uids = User.where('app_version IS NOT ?', nil).where('app_version >= ?', min_version.to_s).map(&:id) 
    return self.newcomers.where(user_id: uids)
  end 

  def self.questions_done(min = 1) 
    self.where('num_questions_done >= ?', min) 
  end 

  def self.snippets_done(min = 1)
    self.where('num_snippets_done >= ?', min) 
  end 

  def self.something_done 
    self.where('num_snippets_done > ? OR num_questions_done > ?', 0,0)
  end 

  def self.something_clicked
    self.where('num_snippets_clicked > ? OR num_questions_clicked > ?', 0,0)
  end 

  def self.seen_stats
    self.where('time_on_stats > ?', 0)
  end 

  def self.some_time_spent
    self.where('time_on_snippets > ? OR time_on_questions > ? OR time_on_stats > ?', 0,0,0)
  end 

  def self.probability_questions_y_given_x(x = 1,y = 1) 
    return 0 if (x < 1 || y < 1) 
    return 100 if (y <= x) 

    num_y = self.questions_done(y).map(&:user_id).uniq.count
    num_x = self.questions_done(x).map(&:user_id).uniq.count

    return ((num_y.to_f / num_x) * 100).round(2) 
  end 

  def self.probability_snippets_y_given_x(x = 1,y = 1, post_version_two = false) 
    return 0 if (x < 1 || y < 1) 
    return 100 if (y <= x) 

    num_y = self.snippets_done(y).map(&:user_id).uniq.count 
    num_x = self.snippets_done(x).map(&:user_id).uniq.count 

    return ((num_y.to_f / num_x) * 100).round(2) 
  end 

end
