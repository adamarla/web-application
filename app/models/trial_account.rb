# == Schema Information
#
# Table name: trial_accounts
#
#  id         :integer         not null, primary key
#  teacher_id :integer
#  school     :string(255)
#  zip_code   :string(30)
#  country    :integer
#  created_at :datetime
#  updated_at :datetime
#

class TrialAccount < ActiveRecord::Base
  belongs_to :teacher

  validates :school, :presence => true
  validates :zip_code, :presence => true
  validates :country, :presence => true
end
