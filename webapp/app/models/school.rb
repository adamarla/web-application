# == Schema Information
#
# Table name: schools
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  street_address :string(255)
#  city           :string(255)
#  state          :string(255)
#  zip_code       :string(255)
#  phone          :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class School < ActiveRecord::Base
  has_many :students 
  has_many :teachers
  has_one :account
end
