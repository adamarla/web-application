# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer         not null, primary key
#  student_id :integer
#  package_id :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Subscription < ActiveRecord::Base
  # attr_accessible :package_id, :student_id
  belongs_to :student
  belongs_to :package

end
