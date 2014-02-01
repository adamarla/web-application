# == Schema Information
#
# Table name: remarks
#
#  id                 :integer         not null, primary key
#  x                  :integer
#  y                  :integer
#  tex                :text
#  graded_response_id :integer
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#

class Remark < ActiveRecord::Base
  # attr_accessible :graded_response_id, :tex, :x, :y
  belongs_to :graded_response

end
