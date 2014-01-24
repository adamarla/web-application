# == Schema Information
#
# Table name: aggr_teacher_topics
#
#  id              :integer         not null, primary key
#  aggregator_id   :integer
#  aggregator_type :string(20)
#  topic_id        :integer
#  benchmark       :float
#  average         :float
#  attempts        :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

class AggrByTopic < ActiveRecord::Base

  has_one :topic
  has_one :aggregator, :polymorphic => true

  def self.for_teacher(teacher_id)
    AggrByTopic.where(aggregator_id: teacher_id, :aggregator_type: "teacher")
  end

  def self.on_topic(topic_id)
    AggrByTopic.where(topic_id: topic_id)
  end
  
  def self.build_for_teacher(teacher_id)
    grs=[]
    Teacher.find(teacher_id).quizzes.each do |q|
      grs+=GradedResponse.in_quiz(q).graded
    end

    vals = {}
    grs.each do |gr|
      q_selection = gr.q_selection
      teacher_id  = q_selection.quiz.teacher_id
      topic_id    = q_selection.question.topic_id

      key = "#{teacher_id}-#{topic_id}"
      val = vals[key]
      if val.nil?
        val = { marks: 0, out_of: 0, count: 0 }
        vals[key] = val
      end
      val[:marks]+= gr.marks
      val[:out_of]+= gr.subpart.marks
      val[:count]+=1
    end

    vals.each do |key, val|
      teacher_id,topic_id = key.split('-')
      benchmark = (val[:out_of]/val[:count].to_f).round(2)
      average = (val[:marks]/val[:count].to_f).round(2)
      count = val[:count]
      att = AggrByTopic.new aggregator_id: teacher_id.to_i,
                            aggregator_type: "teacher",
                            topic_id: topic_id.to_i,
                            benchmark: benchmark,
                            average: average,
                            attempts: count
      att.save
    end
  end
end

