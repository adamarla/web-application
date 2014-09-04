# == Schema Information
#
# Table name: kaagaz
#
#  id      :integer         not null, primary key
#  path    :string(40)
#  stab_id :integer
#

class Kaagaz < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :stab 
  has_many :remarks, dependent: :destroy 

  validates :path, presence: true
  validates :path, uniqueness: { scope: :stab_id }
end
