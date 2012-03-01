# == Schema Information
#
# Table name: verticals
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Vertical < ActiveRecord::Base
  has_many :topics 

  validates :name, :presence => true

  before_save :humanize_name

  private 

    def humanize_name
      self.name = self.name.humanize
    end

end
