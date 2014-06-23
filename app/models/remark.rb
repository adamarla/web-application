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
#  examiner_id        :integer
#

class Remark < ActiveRecord::Base
  # attr_accessible :graded_response_id, :tex, :x, :y
  belongs_to :graded_response
  belongs_to :tex_comment
  belongs_to :doodle
  belongs_to :examiner # if doodle then doodle's author else the examiner who graded the attempt

  after_create :seal 

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

  def examiner_id? 
    self.doodle_id.nil? ? self.graded_response.examiner_id : self.doodle.examiner_id
  end 

  private 
      def seal 
        update_attribute :examiner_id, examiner_id?  
      end 

end
