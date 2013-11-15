# == Schema Information
#
# Table name: comments
#
#  id          :integer         not null, primary key
#  x           :integer
#  y           :integer
#  tex         :text
#  examiner_id :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Comment < ActiveRecord::Base
  attr_accessible :examiner_id, :tex, :x, :y
end
