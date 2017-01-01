# == Schema Information
#
# Table name: usages
#
#  id                    :integer         not null, primary key
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
#  date                  :integer         default(0)
#  num_stats_loaded      :integer         default(0)
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

  def total_time_spent 
    return (time_on_stats + time_on_snippets + time_on_questions)
  end 

  def self.newcomers
    where('user_id > ?', 537).where('user_id NOT IN (?)', [1409,4260]).order(:id)
  end 

  def self.done_in(version = 0)
    users = self.newcomers 
    return users if version < 1 

    exact_match = version.is_a?(Float)
    users = exact_match ? users.where(version: version) : 
                         users.where('version >= ? AND version < ?', version, version + 1)
    return self.where(user_id: users.map(&:id)) 
  end 

  def self.questions_done(min = 1, version = 0) 
    self.done_in(version).where('num_questions_done >= ?', min) 
  end 

  def self.snippets_done(min = 1, version = 0)
    self.done_in(version).where('num_snippets_done >= ?', min) 
  end 

  def self.something_done(version = 0) 
    self.done_in(version).where('num_snippets_done > ? OR num_questions_done > ?', 0,0)
  end 

  def self.something_clicked(version = 0)
    self.done_in(version).where('num_snippets_clicked > ? OR num_questions_clicked > ?', 0,0)
  end 

  def self.seen_stats(version = 0)
    self.done_in(version).where('time_on_stats > ?', 0)
  end 

  def self.probability_questions_y_given_x(x = 1,y = 1, version = 0) 
    return 0 if (x < 1 || y < 1) 
    return 100 if (y <= x) 

    num_y = self.questions_done(y, version).map(&:user_id).uniq.count
    num_x = self.questions_done(x, version).map(&:user_id).uniq.count

    return ((num_y.to_f / num_x) * 100).round(2) 
  end 

  def self.probability_snippets_y_given_x(x = 1,y = 1, version = 0) 
    return 0 if (x < 1 || y < 1) 
    return 100 if (y <= x) 

    num_y = self.snippets_done(y, version).map(&:user_id).uniq.count 
    num_x = self.snippets_done(x, version).map(&:user_id).uniq.count 

    return ((num_y.to_f / num_x) * 100).round(2) 
  end 

  def self.average_time_solving(version = 0) 
    x = self.something_done(version)
    return 0 if x.blank?

    return (x.map(&:time_solving).inject(:+) / x.map(&:user_id).uniq.count.to_f) 
  end 

  def self.session_length(version = 0)
    x = self.something_done(version) 
    return 0 if x.blank? 

    return (x.map(&:total_time_spent).inject(:+) / x.map(&:user_id).uniq.count.to_f) 
  end 

  def self.in_time_range(a,b,version = 0) 
    return if (a < 0 || b < 0) 
    if (a > b) 
      c = a 
      a = b 
      b = c 
    end 

    u = Usage.done_in(version) 
    return u.select{ |x| t = x.total_time_spent ; t >= a && t <= b }
  end 

end
