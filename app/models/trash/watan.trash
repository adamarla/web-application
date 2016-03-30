# == Schema Information
#
# Table name: watan
#
#  id           :integer         not null, primary key
#  name         :string(50)
#  alpha_2_code :string(255)
#

class Watan < ActiveRecord::Base
  def self.collection
    Watan.all.map{ |c|
      {
#       :id    => c.id,
        :label => c.name,
        :value => c.alpha_2_code
      } 
    } 
  end

  def self.names
    []
    Watan.all.each do |c|
      [].push(c.name)  
    end
  end 

end
