# == Schema Information
#
# Table name: analgesics
#
#  id        :integer         not null, primary key
#  uid       :string(20)
#  num_shown :integer         default(0)
#  disabled  :boolean         default(FALSE)
#  category  :string(20)
#

class Analgesic < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :uid, presence: true 
  validates :uid, uniqueness: true 
end
