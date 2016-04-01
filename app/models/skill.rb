# == Schema Information
#
# Table name: skills
#
#  id         :integer         not null, primary key
#  chapter_id :integer
#

class Skill < ActiveRecord::Base

  def path 
    return "skill/#{self.id}"
  end 

end
