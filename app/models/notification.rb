# == Schema Information
#
# Table name: notifications
#
#  id           :integer         not null, primary key
#  uid          :string(40)
#  question_id  :integer
#  num_received :integer         default(0)
#  num_opened   :integer         default(0)
#

class Notification < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :uid, uniqueness: true 
  belongs_to :question 
end
