# == Schema Information
#
# Table name: favourites
#
#  id          :integer         not null, primary key
#  teacher_id  :integer
#  question_id :integer
#

class Favourite < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :question
end
