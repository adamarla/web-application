# == Schema Information
#
# Table name: jokes
#
#  id       :integer         not null, primary key
#  uid      :string(15)
#  image    :boolean         default(FALSE)
#  num_jotd :integer
#

class Joke < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :uid, presence: true 
  validates :uid, uniqueness: true 
end
