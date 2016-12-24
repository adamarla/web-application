# == Schema Information
#
# Table name: wtps
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  price_per_month :integer
#  agreed          :boolean         default(FALSE)
#  num_refusals    :integer         default(0)
#  first_asked_on  :integer         default(0)
#  agreed_on       :integer         default(0)
#

# Wtp = willingness to pay 
class Wtp < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :user 

  validates :user_id, uniqueness: true
  validates :price_per_month, numericality: { only_integer: true, greater_than: 0 }
  validates :num_refusals, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :agreed_on, numericality: { greater_than_or_equal_to: :first_asked_on }, if: :agreed_on_changed?

  def self.newcomers
    where('user_id > ?', 537).where('user_id NOT IN (?)', [1409,4260]).order(:id)
  end 

end # of class
