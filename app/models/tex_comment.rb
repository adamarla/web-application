# == Schema Information
#
# Table name: tex_comments
#
#  id          :integer         not null, primary key
#  text        :text
#  examiner_id :integer
#  trivial     :boolean
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class TexComment < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :examiner
  has_many :remarks

  validates :text, uniqueness: true
end
