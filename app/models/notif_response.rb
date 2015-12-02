# == Schema Information
#
# Table name: notif_responses
#
#  id            :integer         not null, primary key
#  category      :string(10)
#  uid           :string(20)
#  parent_id     :integer
#  num_sent      :integer         default(0)
#  num_received  :integer         default(0)
#  num_failed    :integer         default(0)
#  num_dismissed :integer         default(0)
#  num_opened    :integer         default(0)
#

class NotifResponse < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :category, presence: true 
  validates :uid, presence: true 
  validates :uid, uniqueness: { scope: :category }
end
