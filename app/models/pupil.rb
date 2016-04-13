# == Schema Information
#
# Table name: pupils
#
#  id              :integer         not null, primary key
#  first_name      :string(50)
#  last_name       :string(50)
#  email           :string(100)
#  gender          :integer
#  birthday        :string(50)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  known_associate :boolean         default(FALSE)
#

class Pupil < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :email, presence: true
  validates :email, uniqueness: true 

  has_many :attempts, dependent: :destroy
  has_many :devices, dependent: :destroy
  has_many :expertise, dependent: :destroy 

  def name 
    return "#{self.first_name} #{self.last_name}"
  end 

  def days_active
    start_date = self.created_at.to_date
    devices = Device.where(pupil_id: self.id).order(:created_at) 

    if devices.blank? 
      end_date = Date.today
    else
      live = devices.map(&:live).include?(true) 
      end_date = live ? Date.today : devices.last.updated_at.to_date
    end 
    return (end_date - start_date).to_i
  end 

  def days_since_registration
    return (Date.today - self.created_at.to_date).to_i
  end 

  def returning_user? 
    a = Attempt.where(pupil_id: self.id) 
    return false if a.empty? 
    format = "%d/%m/%y"
    dates = a.map{ |x| x.updated_at.to_date.strftime(format) }
    return true if dates.uniq.count > 1 
    signed_up_on = self.created_at.to_date.strftime(format)
    return signed_up_on != dates.first
  end 

  def num_attempts(count_retries = true)
    a = Attempt.where(pupil_id: self.id)
    return a.count unless count_retries
    return (a.empty? ? 0 : a.map(&:num_attempts).inject(&:+))
  end 

  def total_time_solving
    a = Attempt.where(pupil_id: self.id) 
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

  def self.profile(pids)
    # returns a hash where each value is an array of values extracted for passed pids
    p = Pupil.where(id: pids) 
    ret = {} 
    [:num_attempts, :days_between_attempts, :days_active, :total_time_solving].each do |k| 
      ret[k] = p.map(&k)
    end 
    return ret
  end 


end
