# == Schema Information
#
# Table name: users
#
#  id               :integer         not null, primary key
#  first_name       :string(50)
#  last_name        :string(50)
#  email            :string(100)
#  gender           :integer
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  join_date        :date
#  num_invites_sent :integer         default(0)
#  app_version      :string(10)
#  facebook_login   :boolean         default(FALSE)
#  birthday         :integer         default(0)
#

class User < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :email, presence: true
  validates :email, uniqueness: true 

  has_many :attempts, dependent: :destroy
  has_many :devices, dependent: :destroy
  has_many :expertise, dependent: :destroy 
  has_one :wtp, dependent: :destroy 

  def name 
    return "#{self.first_name} #{self.last_name}"
  end 

  def joined_on
    # We consider the user to have joined *not* on the day
    # he registers but on the day he makes his first attempt

    return self.join_date unless self.join_date.nil? 
    usages = Usage.where(user_id: self.id) 

    return nil if usages.blank?

    first_use = usages.sort{ |x,y| x.date.to_date <=> y.date.to_date }.first 
    date = first_use.date.to_date 
    self.update_attribute(:join_date, date) 
    return date 
  end 

  def total_time_in_app 
    return Usage.where(user_id: self.id).map(&:total_time_spent).inject(:+)
  end 

  def self.newcomers
    where('id > ?', 537).where('id NOT IN (?)', [1409, 4260]).order(:id)
  end 

  def self.version(v)
    self.newcomers.where(app_version: v).order(:id)
  end 

  def self.days_active(n, app_version = 0)
    u = Usage.newcomers.something_done(app_version) 
    ids = u.map(&:user_id) 
    uids = ids.uniq 
    users = []

    uids.each do |j| 
      users.push(j) if ids.count(j) == n 
    end 
    return User.where(id: users) 
  end 

  def self.min_active_days(n, app_version = 0) 
    u = Usage.newcomers.something_done(app_version) 
    ids = u.map(&:user_id) 
    uids = ids.uniq 
    users = []

    uids.each do |j| 
      users.push(j) if ids.count(j) >= n 
    end 
    return User.where(id: users) 
  end 

  def self.return_probability(app_version = 0)
    p = (User.min_active_days(2, app_version).count * 100)/ User.min_active_days(1, app_version).count.to_f 
    return p.round(2) 
  end 


  def days_since_registration
    return (Date.today - self.created_at.to_date).to_i
  end 

  def returning_user? 
    a = Attempt.where(user_id: self.id) 
    return false if a.empty? 
    format = "%d/%m/%y"
    dates = a.map{ |x| x.updated_at.to_date.strftime(format) }
    return true if dates.uniq.count > 1 
    signed_up_on = self.created_at.to_date.strftime(format)
    return signed_up_on != dates.first
  end 

  def num_attempts(count_retries = true)
    a = Attempt.where(user_id: self.id)
    return a.count unless count_retries
    return (a.empty? ? 0 : a.map(&:num_attempts).inject(&:+))
  end 

  def total_time_solving
    a = Attempt.where(user_id: self.id) 
    return 0 if a.blank?
    total_times = a.map(&:total_time).select{ |t| !t.nil? }
    return (total_times.blank? ? 0 : total_times.inject(&:+))
  end 

  def days_between_attempts
    return self.num_attempts > 0 ? (self.days_active / self.num_attempts.to_f).round(2) : 0
  end 

  def self.registered_in_last(n)
    select{ |p| p.days_since_registration <= n }
  end 

  def self.with_min_attempts(n)
    select{ |p| p.num_attempts >= n } 
  end 

  def self.profile(uids)
    # returns a hash where each value is an array of values extracted for passed uids
    p = User.where(id: uids) 
    ret = {} 
    [:num_attempts, :days_between_attempts, :days_active, :total_time_solving].each do |k| 
      ret[k] = p.map(&k)
    end 
    return ret
  end 


end
