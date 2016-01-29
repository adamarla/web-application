# == Schema Information
#
# Table name: attempts
#
#  id             :integer         not null, primary key
#  pupil_id       :integer
#  question_id    :integer
#  checked_answer :boolean         default(FALSE)
#  num_attempts   :integer         default(0)
#  got_right      :boolean
#  max_opened     :integer         default(0)
#  max_time       :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  total_time     :integer
#  seen_summary   :boolean         default(FALSE)
#  time_to_answer :integer
#  time_on_cards  :string(40)
#  num_surrender  :integer
#  time_to_bingo  :integer         default(0)
#

class Attempt < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :pupil 
  validates :max_opened, numericality: { only_integer: true, less_than: 10 } 

  def total_time_on_cards 
    return 0 if time_on_cards.blank? 
    return time_on_cards.delete("[]").split(',').map(&:to_i).inject(&:+)
  end 

  def average_time 
    # Returns average number of seconds
    return 0 if (total_time.nil? || num_attempts == 0) 
    return (total_time / num_attempts.to_f).round(2) 
  end 

  def self.with_times(avg_time_threshold = 1200) 
    pids = [*1..Pupil.last.id] - [1,3]
    where(pupil_id: pids).where('total_time > ?', 0).select{ |a| a.average_time < avg_time_threshold }
  end 

end
