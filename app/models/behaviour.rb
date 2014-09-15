# == Schema Information
#
# Table name: behaviours
#
#  id         :integer         not null, primary key
#  student_id :integer
#  n_stabs    :integer         default(0)
#  n_reccos   :integer         default(0)
#  n_puzzles  :integer         default(0)
#

class Behaviour < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :student
end
