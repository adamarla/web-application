# == Schema Information
#
# Table name: puzzles
#
#  id             :integer         not null, primary key
#  text           :text
#  question_id    :integer
#  version        :integer         default(0)
#  n_picked       :integer         default(0)
#  active         :boolean         default(FALSE)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  last_picked_on :date
#

class Puzzle < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :question
  validates :version, uniqueness: { scope: :question_id } 
  validates :question_id, uniqueness: true 

  def self.next # call only via controller every midnight
    n = Puzzle.where(active: false).order(:n_picked).first
    n.pick unless n.nil?
  end 

  def self.of_the_day
    where(active: true).first
  end 

  def self.days_ago(n)
    d = n.days.ago.to_date
    Puzzle.where(last_picked_on: d).first
  end 

  def pick 
    a = Puzzle.where(active: true).first 
    a.update_attribute(:active, false) unless a.nil?
    self.update_attributes active: true, n_picked: (self.n_picked + 1), last_picked_on: Date.today
  end 

  def expires_in?
    return nil unless self.active 
    return ( 86400 - Time.now.in_time_zone('Kolkata').seconds_since_midnight ).floor
  end 

end
