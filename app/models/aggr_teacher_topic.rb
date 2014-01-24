# == Schema Information
#
# Table name: aggr_teacher_topics
#
#  id             :integer         not null, primary key
#  teacher_id     :integer
#  topic_id       :integer
#  benchmark      :float
#  average_score  :float
#  basis_attempts :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

class AggrTeacherTopic < ActiveRecord::Base

  has_one :teacher
  has_one :topic

  def self.of_teacher(teacher_id)
    AggrTeacherTopic.where(teacher_id: teacher_id)
  end

  def self.on_topic(topic_id)
    AggrTeacherTopic.where(topic_id: topic_id)
  end
  
  def self.aggregate_grs(grs)
    atts = {}
    grs.each do |gr|
      q_selection = gr.q_selection
      question    = q_selection.question
      topic_id    = question.topic_id
      teacher_id  = q_selection.quiz.teacher_id

      key = "#{teacher_id}-#{topic_id}"
      att = atts[key]
      if att.nil?
        att = AggrTeacherTopic.new teacher_id: teacher_id, 
                                   topic_id: topic_id,
                                   benchmark: 0.0,
                                   average_score: 0,
                                   basis_attempts: 0
        atts[key] = att
      end
      marks=gr.marks
      outof=gr.subpart.marks
      basis=att[:basis_attempts]+1
      att[:benchmark]=(att[:benchmark]*att[:basis_attempts]+outof)/basis
      att[:average_score]=(att[:average_score]*att[:basis_attempts]+marks)/basis
      att[:basis_attempts]=basis
    end

    atts.values.each do |att|
      att.save
    end
  end

end
