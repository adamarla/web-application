# == Schema Information
#
# Table name: coursework
#
#  id           :integer         not null, primary key
#  milestone_id :integer
#  quiz_id      :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class Coursework < ActiveRecord::Base
  attr_accessible :milestone_id, :quiz_id
end
