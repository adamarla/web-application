# == Schema Information
#
# Table name: wtps
#
#  id             :integer         not null, primary key
#  user_id        :integer
#  price_per_week :integer
#  agreed         :boolean         default(FALSE)
#  num_refusals   :integer         default(0)
#  first_asked_on :integer
#  agreed_on      :integer
#

# Wtp = willingness to pay 
class Wtp < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :user 

  validates :user_id, uniqueness: true
  validates :price_per_week, numericality: { only_integer: true, greater_than: 0 }
  validates :num_refusals, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :agreed_on, numericality: { greater_than_or_equal_to: :first_asked_on }, if: :agreed_on_changed?
end
