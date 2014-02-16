# == Schema Information
#
# Table name: remarks
#
#  id                 :integer         not null, primary key
#  x                  :integer
#  y                  :integer
#  graded_response_id :integer
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  tex_comment_id     :integer
#  examiner_id        :integer
#  live               :boolean         default(TRUE)
#

class Remark < ActiveRecord::Base
  # attr_accessible :graded_response_id, :tex, :x, :y
  belongs_to :graded_response
  belongs_to :tex_comment

end
