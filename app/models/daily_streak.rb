# == Schema Information
#
# Table name: daily_streaks
#
#  id           :integer         not null, primary key
#  date         :string(30)
#  pupil_id     :integer
#  streak_total :integer         default(0)
#

class DailyStreak < ActiveRecord::Base
  # attr_accessible :title, :body
  
  validates :date, presence: true 
  validates :date, uniqueness: { scope: :pupil_id } 
end
