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
#

class Attempt < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :pupil 
  validates :max_opened, numericality: { only_integer: true, less_than: 10 } 
end
