# == Schema Information
#
# Table name: authors
#
#  id         :integer         not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  is_admin   :boolean         default(FALSE)
#  first_name :string(30)
#  last_name  :string(30)
#  live       :boolean         default(FALSE)
#  email      :string(255)
#

class Author < ActiveRecord::Base
  validates :email, presence: true 
  validates :email, uniqueness: true

  def name 
    return self.last_name.nil? ? self.first_name : "#{self.first_name} #{self.last_name}"
  end 

  def name=(name)
    split = name.split
    last = split.count - 1
    self.first_name = split.first.humanize

    if last > 0
      middle = split[1...last].map{ |m| m.humanize[0] }.join('.')
      self.last_name = middle.empty? ? "#{split.last.humanize}" : "#{middle} #{split.last.humanize}"
    end
  end

  def self.available
    where(live: true)
  end

end # of class
