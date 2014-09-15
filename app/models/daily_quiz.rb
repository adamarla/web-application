# == Schema Information
#
# Table name: daily_quizzes
#
#  id         :integer         not null, primary key
#  qids       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class DailyQuiz < ActiveRecord::Base
  # attr_accessible :title, :body

  def self.next(ignore_past_n_days = 2)
    ignore_ids = DailyQuiz.last(ignore_past_n_days).map(&:qids).map{ |j| j.split(',').map(&:to_i) }.flatten.uniq
    all = Question.available.difficulty(3).map(&:id) 
    use = (all - ignore_ids).sample(20)
    DailyQuiz.create qids: use.join(',')
  end

  def self.load 
    qids = DailyQuiz.last.qids.split(',').map(&:to_i)
    return Question.where(id: qids)
  end 

end
