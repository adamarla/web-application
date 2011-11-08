# == Schema Information
#
# Table name: examiners
#
#  id            :integer         not null, primary key
#  num_contested :integer         default(0)
#  created_at    :datetime
#  updated_at    :datetime
#  secret_key    :string(255)
#  is_admin      :boolean         default(FALSE)
#

class Examiner < ActiveRecord::Base
  has_one :account, :as => :loggable
  has_many :graded_responses

  attr_accessible :num_contested
  before_create :set_secret_key

  private 
    def set_secret_key 
      x = rand(36**16).to_s(36).rjust(16,"0")
      y = rand(36**16).to_s(36).rjust(16,"0")
      self.secret_key = x + y
    end 

end
