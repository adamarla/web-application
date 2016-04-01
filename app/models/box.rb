# == Schema Information
#
# Table name: boxes
#
#  id             :integer         not null, primary key
#  uid            :string(15)
#  chapter_id     :integer
#  language_id    :integer
#  min_difficulty :integer
#  max_difficulty :integer
#  of_questions   :boolean         default(FALSE)
#  of_skills      :boolean         default(FALSE)
#  of_snippets    :boolean         default(FALSE)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

class Box < ActiveRecord::Base
  validates :chapter_id, numericality: { only_integer: true, greater_than: 0 }
  validates :chapter_id, uniqueness: { scope: [:language_id, :min_difficulty, :max_difficulty] } 

  belongs_to :chapter 
  belongs_to :language 
end
