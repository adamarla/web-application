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
#  num_invites_sent :integer         default(0)
#  facebook_login   :boolean         default(FALSE)
#  birthday         :integer         default(0)
#  version          :float           default(1.0)
#  time_zone        :string(50)
#  join_date        :integer
#  phone            :string(20)
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
  before_update :set_phone_number, if: :email_changed? 

  def name 
    return "#{self.first_name} #{self.last_name}"
  end 

  def joined_on
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
      set_phone_number
    end 

    def set_phone_number
      # We've noticed that many people embed a 10-digit number 
      # in their e-mail IDs that look remarkably like phone numbers. 
      # Hence, extract the 10-digits and store as the (tentative) phone # 
      m = self.email.match(/\d{10}/)
      ph = m.nil? ? nil : m[0]
      self.phone = ph unless ph.nil?
    end 

end # of model 
