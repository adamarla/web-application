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
#  tex_comment_id     :integer
#

class Remark < ActiveRecord::Base
  # attr_accessible :graded_response_id, :tex, :x, :y
  belongs_to :graded_response
  belongs_to :tex_comment

end
