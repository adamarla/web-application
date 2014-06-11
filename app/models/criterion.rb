# == Schema Information
#
# Table name: criteria
#
#  id         :integer         not null, primary key
#  text       :string(255)
#  penalty    :integer         default(0)
#  account_id :integer
#  standard   :boolean         default(TRUE)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Criterion < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :text, presence: true
  validates :penalty, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def self.standard
    where(standard: true)
  end 

  def num_stars?
    return ((100 - self.penalty) / 20.0).round
  end 

end
