# == Schema Information
#
# Table name: examiners
#
#  id            :integer         not null, primary key
#  num_contested :integer         default(0)
#  created_at    :datetime
#  updated_at    :datetime
#

class Examiner < ActiveRecord::Base
  has_one :account 
  has_many :questions 
end
