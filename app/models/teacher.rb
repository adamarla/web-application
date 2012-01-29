# == Schema Information
#
# Table name: teachers
#
#  id         :integer         not null, primary key
#  first_name :string(255)
#  last_name  :string(255)
#  created_at :datetime
#  updated_at :datetime
#  school_id  :integer
#

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

#     ___:has_many____     __:belongs_to___  
#    |                |   |                | 
# Teacher ---------> Grade ---------> Yardstick
#    |                |   |                | 
#    |__:belongs_to___|   |___:has_many____| 
#    

require 'rexml/document'
include REXML
include ApplicationUtil

class Teacher < ActiveRecord::Base
  has_many :quizzes, :dependent => :destroy 
  belongs_to :school 
  has_one :account, :as => :loggable

  has_many :faculty_rosters
  has_many :sektions, :through => :faculty_rosters

  has_many :grades
  has_many :yardsticks, :through => :grades

  has_many :specializations
  has_many :subjects, :through => :specializations

  validates :first_name, :last_name, :presence => true  

  before_save  :humanize_name
  after_create :build_grade_table
  after_save   :reset_login_info

  # When would one want to 'destroy' a teacher? And what would it mean? 
  # 
  # My guess is that a teacher should NEVER be 'destroyed' even if he/she 
  # is expected to quit teaching for the forseeable future (say, due to child birth). 
  # You never know, he/she might just get back to teaching. Moreover, the teacher's 
  # past record can be a good reference for the new school.

  #after_validation :setup_account, :if => :first_time_save?
  before_destroy :destroyable? 

  def username?
    self.account.username
  end 

  def name( who_wants_to_know = :guest )
    case who_wants_to_know 
      when :teacher, :admin, :school
        return "#{self.first_name} #{self.last_name} (#{self.username?})"
      else 
        return "#{self.first_name} #{self.last_name}"
    end
  end 

  def print_name
    return "#{self.first_name} #{self.last_name}"
  end

  def build_xml(questions, students) 
  end 

  def build_tex 
  end 

  def compile_tex
  end 

  def roster 
    # Yes, yes.. We could have gotten the same thing by simply calling self.sektions
    # But if we return an ActiveRelation, then we get the benefit of lazy loading
    Sektion.joins(:faculty_rosters).where('faculty_rosters.teacher_id = ?', self.id)
  end 

  def set_subjects(list_of_ids = [])
    list_of_ids.each_with_index { |a, index| list_of_ids[index] = a.to_i } 
    self.subjects = Subject.where :id => list_of_ids
  end

  private 
    
    def reset_login_info
      new_prefix = username_prefix_for self, :teacher
      u = self.account.username.sub(/^\w+\./, "#{new_prefix}.")
      e = self.account.email.sub(/^\w+\./, "#{new_prefix}.")
      self.account.update_attributes(:username => u, :email => e)
    end

    def setup_account 
      self.build_account
    end 

    def destroyable? 
      return false 
    end 

    def first_time_save? 
      self.new_record? || !self.account
    end 

    def humanize_name
      self.first_name = self.first_name.humanize
      self.last_name = self.last_name.humanize
    end 

    def build_grade_table
      Yardstick.select('id, default_allotment').each do |y|
        grade = self.grades.new :allotment => y.default_allotment, :yardstick_id => y.id
        break if !grade.save
      end
    end 

end
