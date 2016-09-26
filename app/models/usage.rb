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

  def time_solving
    return (time_on_snippets + time_on_questions)
  end 

  def self.newcomers
    where('user_id > ? AND user_id != ?', 537,1409).order(:id)
  end 

  def self.on_app_version(version = 0)
    return self.newcomers if version < 1 

    newcomers = User.newcomers.map(&:id)
    if  (version < 2) 
      uids = newcomers & User.where(app_version: nil).map(&:id) 
    else 
      uids = newcomers & User.where('app_version IS NOT ?', nil).where('app_version >= ?', version.to_s).map(&:id)
    end 
    return self.where(user_id: uids)
  end 

  def self.questions_done(min = 1, app_version = 0) 
    self.on_app_version(app_version).where('num_questions_done >= ?', min) 
  end 

  def self.snippets_done(min = 1, app_version = 0)
    self.on_app_version(app_version).where('num_snippets_done >= ?', min) 
  end 

  def self.something_done(app_version = 0) 
    self.on_app_version(app_version).where('num_snippets_done > ? OR num_questions_done > ?', 0,0)
  end 

  def self.something_clicked(app_version = 0)
    self.on_app_version(app_version).where('num_snippets_clicked > ? OR num_questions_clicked > ?', 0,0)
  end 

  def self.seen_stats(app_version = 0)
    self.on_app_version(app_version).where('time_on_stats > ?', 0)
  end 

  def self.some_time_spent(app_version = 0)
    self.on_app_version(app_version).where('time_on_snippets > ? OR time_on_questions > ? OR time_on_stats > ?', 0,0,0)
  end 

  def self.probability_questions_y_given_x(x = 1,y = 1, app_version = 0) 
    return 0 if (x < 1 || y < 1) 
    return 100 if (y <= x) 

    num_y = self.questions_done(y, app_version).map(&:user_id).uniq.count
    num_x = self.questions_done(x, app_version).map(&:user_id).uniq.count

    return ((num_y.to_f / num_x) * 100).round(2) 
  end 

  def self.probability_snippets_y_given_x(x = 1,y = 1, app_version = 0) 
    return 0 if (x < 1 || y < 1) 
    return 100 if (y <= x) 

    num_y = self.snippets_done(y, app_version).map(&:user_id).uniq.count 
    num_x = self.snippets_done(x, app_version).map(&:user_id).uniq.count 

    return ((num_y.to_f / num_x) * 100).round(2) 
  end 

  def self.average_time_solving(app_version = 0) 
    x = self.something_done(app_version)
    return 0 if x.blank?

    return (x.map(&:time_solving).inject(:+) / x.map(&:user_id).uniq.count.to_f) 
  end 

end
