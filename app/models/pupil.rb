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

  def returning_user? 
    a = Attempt.where(pupil_id: self.id) 
    return false if a.empty? 
    format = "%d/%m/%y"
    dates = a.map{ |x| x.updated_at.to_date.strftime(format) }
    return true if dates.uniq.count > 1 
    signed_up_on = self.created_at.to_date.strftime(format)
    return signed_up_on != dates.first
  end 


end
