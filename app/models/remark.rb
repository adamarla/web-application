# == Schema Information
#
# Table name: remarks
#
#  id             :integer         not null, primary key
#  x              :integer
#  y              :integer
#  attempt_id     :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  tex_comment_id :integer
#  doodle_id      :integer
#  examiner_id    :integer
#  kaagaz_id      :integer
#

class Remark < ActiveRecord::Base
  # attr_accessible :attempt_id, :tex, :x, :y
  belongs_to :attempt
  belongs_to :doodle
  belongs_to :kaagaz
  belongs_to :tex_comment
  belongs_to :examiner # if doodle then doodle's author else the examiner who graded the attempt

  after_create :seal 

  def self.by(id)
    live.where(attempt_id: Attempt.assigned_to(id).map(&:id)) + 
    sandboxed.where(doodle_id: Doodle.where(examiner_id: id).map(&:id))
  end

  def self.live
    where(doodle_id: nil)
  end

  def self.sandboxed
    where('doodle_id IS NOT ?', nil)
  end

  private 
      def examiner_id? 
        kaagaz_id.nil? ? (doodle_id.nil? ? attempt.examiner_id : doodle.examiner_id) : kaagaz.stab.examiner_id   
      end 

      def seal 
        update_attribute :examiner_id, examiner_id?  
        if doodle_id.nil? # for attempt or kaagaz
          tex_comment.up_used_count() 
          q = attempt_id.nil? ? kaagaz.stab.question : attempt.subpart.question
          q.commentaries.create(tex_comment_id: tex_comment_id) unless q.nil?
        end
      end 

end
