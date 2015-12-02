# == Schema Information
#
# Table name: jokes
#
#  id        :integer         not null, primary key
#  uid       :string(20)
#  image     :boolean         default(FALSE)
#  num_shown :integer         default(0)
#  disabled  :boolean         default(FALSE)
#

class Joke < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :uid, presence: true 
  validates :uid, uniqueness: true 
end
