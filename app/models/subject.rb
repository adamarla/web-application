# == Schema Information
#
# Table name: subjects
#
#  id         :integer         not null, primary key
#  name       :string(30)
#  created_at :datetime
#  updated_at :datetime
#

class Subject < ActiveRecord::Base
  validates :name, :presence => true
end
