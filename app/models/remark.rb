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
#  doodle_id          :integer
#

class Remark < ActiveRecord::Base
  # attr_accessible :graded_response_id, :tex, :x, :y
  belongs_to :graded_response
  belongs_to :tex_comment
  belongs_to :doodle

  def self.by(id)
    live.where(graded_response_id: GradedResponse.assigned_to(id).map(&:id)) + 
    sandboxed.where(doodle_id: Doodle.where(examiner_id: id).map(&:id))
  end

  def self.live
    where(doodle_id: nil)
  end

  def self.sandboxed
    where('doodle_id IS NOT ?', nil)
  end

end
