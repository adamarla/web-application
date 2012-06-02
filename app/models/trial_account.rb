# == Schema Information
#
# Table name: trial_accounts
#
#  id         :integer         not null, primary key
#  teacher_id :integer
#  school     :string(255)
#  zip_code   :string(255)
#  country    :integer
#  created_at :datetime
#  updated_at :datetime
#

class TrialAccount < ActiveRecord::Base
end
