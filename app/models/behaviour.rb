# == Schema Information
#
# Table name: behaviours
#
#  id          :integer         not null, primary key
#  student_id  :integer
#  n_stabs     :integer         default(0)
#  n_reccos    :integer         default(0)
#  n_puzzles   :integer         default(0)
#  n_answers   :integer         default(0)
#  n_solutions :integer         default(0)
#

class Behaviour < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :student

  def up_count(field) # field = [:n_puzzles | :n_stabs | :n_reccos ] 
    n = self[field] + 1
    self.update_attribute field, n
  end 

end
