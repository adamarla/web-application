# == Schema Information
#
# Table name: packages
#
#  id         :integer         not null, primary key
#  title      :string(150)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Package < ActiveRecord::Base
  # attr_accessible :description
  
  has_many :questions
  has_many :bundles

  def self.default
    self.find 1
  end

  def self.non_default
    where('id != 1')
  end

end


