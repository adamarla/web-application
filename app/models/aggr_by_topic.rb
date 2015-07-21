# == Schema Information
#
# Table name: aggr_by_topics
#
#  id              :integer         not null, primary key
#  topic_id        :integer
#  aggregator_id   :integer
#  aggregator_type :string(20)
#  benchmark       :float
#  average         :float
#  attempts        :integer
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

class AggrByTopic < ActiveRecord::Base

  has_one    :topic

  # An aggregate is for a teacher as of now (01/24/14) but can be 
  # for a student, a school or even a geography in future
  belongs_to :aggregator, :polymorphic => true

  def self.for_teacher(teacher_id)
    where(aggregator_id: teacher_id, aggregator_type: "teacher")
  end

  def self.for_topic(topic_id)
    where(topic_id: topic_id)
  end
  
  def self.build(tryouts)
    vals = {}
    tryouts.each do |gr|
      next if gr.feedback == 0 # make sure it is in fact a "graded" response
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
      att = AggrByTopic.for_teacher(teacher_id).for_topic(topic_id).first
      if att.nil?
        att = AggrByTopic.new aggregator_id: teacher_id.to_i,
                              aggregator_type: "teacher",
                              topic_id: topic_id.to_i
      end
      att[:benchmark] = benchmark
      att[:average] = average
      att[:tryouts] = count
      att.save
    end
  end
end

