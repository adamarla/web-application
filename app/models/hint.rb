# == Schema Information
#
# Table name: hints
#
#  id         :integer         not null, primary key
#  text       :text
#  index      :integer
#  subpart_id :integer
#

class Hint < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :subpart 
  validates :text, uniqueness: { scope: :subpart_id }
end
