# == Schema Information
#
# Table name: puzzles
#
#  id          :integer         not null, primary key
#  text        :text
#  question_id :integer
#  version     :integer         default(0)
#  n_picked    :integer         default(0)
#  active      :boolean         default(FALSE)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
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

  def pick 
    a = Puzzle.where(active: true).first 
    a.update_attribute(:active, false) unless a.nil?
    self.update_attributes active: true, n_picked: (self.n_picked + 1)
  end 

end
