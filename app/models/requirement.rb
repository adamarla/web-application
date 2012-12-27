# == Schema Information
#
# Table name: requirements
#
#  id       :integer         not null, primary key
#  text     :string(255)
#  honest   :boolean         default(FALSE)
#  cogent   :boolean         default(FALSE)
#  complete :boolean         default(FALSE)
#  other    :boolean         default(FALSE)
#  weight   :integer         default(-1)
#

class Requirement < ActiveRecord::Base
  validates :text, :presence => true
  validates :weight, :inclusion => { :in => [*-1..4] }

  before_save :ensure_unique_type

  private 
    def ensure_unique_type
      return [self.honest, self.cogent, self.complete, self.other].count(true) == 1
    end 

end
