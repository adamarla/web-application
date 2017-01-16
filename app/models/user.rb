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
#  facebook_login   :boolean         default(FALSE)
#  birthday         :integer         default(0)
#  version          :float           default(1.0)
#  time_zone        :string(50)
#

class User < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :email, presence: true
  validates :email, uniqueness: true 

  has_many :attempts, dependent: :destroy
  has_many :devices, dependent: :destroy
  has_many :expertise, dependent: :destroy 
  has_one :wtp, dependent: :destroy 

  before_create :seal

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

  def returning_user?
    return Usage.where(user_id: self.id).count > 1
  end 

  def days_since_registration
    return (Date.today - self.created_at.to_date).to_i
  end 

  def self.newcomers
    where('id > ?', 537).where('id NOT IN (?)', [1409, 4260]).order(:id)
  end 

  def self.international
    where('time_zone IS NOT ?', nil).where('time_zone <> ? AND time_zone <> ?', "Asia/Kolkata", "Asia/Calcutta")
  end 

  def self.sharers
    newcomers.where('num_invites_sent > ?', 0)
  end 

  def self.version(v)
    v.is_a?(Float) ? where(version: v) : where('version >= ? AND version < ?', v, v + 1)
  end 

  def self.days_active(n, version = 0) 
    u = version == 0 ? self.newcomers : self.newcomers.version(version) 
    ids = u.map(&:id) 
    doer_ids = Usage.where(user_id: ids).map(&:user_id)
    ret = [] 

    ids.each do |j| 
      ret.push(j) if doer_ids.count(j) == n
    end 

    where(id: ret)
  end 

  def self.min_days_active(n, version = 0)
    u = version == 0 ? self.newcomers : self.newcomers.version(version) 
    ids = u.map(&:id) 
    doer_ids = Usage.where(user_id: ids).map(&:user_id)
    ret = [] 

    ids.each do |j| 
      ret.push(j) if doer_ids.count(j) >= n
    end 

    where(id: ret)
  end 

  def self.return_probability(version = 0)
    p = (User.min_days_active(2, version).count * 100)/ User.min_days_active(1, version).count.to_f 
    return p.round(2) 
  end 

  private 
    def seal 
      self.first_name = self.first_name.strip.titleize 
      self.last_name = self.last_name.strip.titleize
    end 

=begin
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
=end

end # of model 
