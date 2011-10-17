class Quiz < ActiveRecord::Base
  belongs_to :teacher 
  has_many :questions 
end
