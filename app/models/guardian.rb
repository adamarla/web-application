# == Schema Information
#
# Table name: guardians
#
#  id         :integer         not null, primary key
#  is_mother  :boolean
#  created_at :datetime
#  updated_at :datetime
#  first_name :string(30)
#  last_name  :string(30)
#

class Guardian < ActiveRecord::Base
  has_many :students
  has_one :account, as: :loggable, dependent: :destroy
  validates_associated :account

  # [:all] ~> [:admin, :guardian, :teacher, :school]
  #attr_accessible

  def self.initial_pwd(student_first_name)
    return student_first_name
  end

  def username?
    self.account.username
  end

  def name
    return self.last_name.nil? ? self.first_name : "#{self.first_name} #{self.last_name}"
  end 

  def name=(name)
    name.gsub! /[\d\.\$\?\(\)\,#]+/,""
    split = name.strip.split
    last = split.count - 1
    self.first_name = split.first.humanize

    if last > 0
      middle = split[1...last].map{ |m| m.humanize[0] }.join('.')
      self.last_name = middle.empty? ? "#{split.last.humanize}" : "#{middle} #{split.last.humanize}"
    end
  end


end
