# == Schema Information
#
# Table name: teachers
#
#  id         :integer         not null, primary key
#  first_name :string(255)
#  last_name  :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  school_id  :integer
#

require 'rexml/document'
include REXML

class Teacher < ActiveRecord::Base
  has_many :quizzes, :dependent => :destroy 
  has_many :questions, :through => :quizzes
  belongs_to :school 
  has_one :account
  has_many :study_groups, :through => :faculty_rosters

  validates :first_name, :last_name, :presence => true  

  # When would one want to 'destroy' a teacher? And what would it mean? 
  # 
  # My guess is that a teacher should NEVER be 'destroyed' even if he/she 
  # is expected to quit teaching for the forseeable future (say, due to child birth). 
  # You never know, he/she might just get back to teaching. Moreover, the teacher's 
  # past record can be a good reference for the new school.

  after_validation :setup_account, :if => :first_time_save?
  before_destroy :destroyable? 

  def build_xml(questions, students) 
  end 

  def build_tex 
  end 

  def compile_tex
  end 

  private 

    def setup_account 
      self.build_account
    end 

    def destroyable? 
      return false 
    end 

    def first_time_save? 
      self.new_record? || !self.account
    end 

end
