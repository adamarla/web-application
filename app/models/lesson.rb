# == Schema Information
#
# Table name: lessons
#
#  id          :integer         not null, primary key
#  title       :string(150)
#  description :text
#  teacher_id  :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Lesson < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :teacher

  validates :title, presence: true

  has_one :video, as: :watchable

  after_create :seal

  def description?
    return self.description || "No description"
  end 

#################################################################
  
  private 
      
      def seal 
        d = self.description.blank? ? nil : self.description
        self.update_attributes(description: d)
      end 
end
