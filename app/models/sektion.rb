# == Schema Information
#
# Table name: sektions
#
#  id         :integer         not null, primary key
#  school_id  :integer
#  klass      :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Sektion < ActiveRecord::Base
  validates :klass, :presence => true 
  validates :name, :presence => true 

  validates :name, :uniqueness => { :scope => [:klass, :school_id] } 

  belongs_to :school

  has_many :student_rosters
  has_many :students, :through => :student_rosters

  has_many :faculty_rosters
  has_many :teachers, :through => :faculty_rosters

  def name 
    return "#{self.klass.to_s}-#{self.name} (#{self.students.count})"
  end 

  def taught_by? (teacher) 
    !( FacultyRoster.where(:sektion_id => self.id, :teacher_id => teacher.id).empty? )
  end 

  def update_student_list ( student_list ) 
    # student_list is a hash of the form : { 1 => true, 2 => false, 3 => true ... }
    # and is actually equal to params[:checked]

    student_list.each { |student_id, assign| 
      student = Student.find student_id 
      if assign 
        student.update_attribute(:sektion_id, self.id) 
      else 
        student.update_attribute(:sektion_id, nil) if student.sektion_id == self.id 
      end 
    } 
  end 

=begin
  This next method is for one-time-call only and then too only from within a migration file
  It has been written as part of the transition scheme for supporting many-to-many mapping 
  between students and sektions. Once the transition is done, this method has no utility!

  Its like the 2 methods written in question.rb. Those were written for subpart support
=end
  def self.build_student_roster
    # Available tables: student_roster and student w/ sektion_id
    Student.all.each do |s|
      roster = StudentRoster.new :student_id => s.id, :sektion_id => s.sektion_id
      roster.save
    end # of students loop  
  end # up  

  def self.unbuild_student_roster
    # Available tables: student_roster and student w/ sektion_id
    # Complication: in the student_roster, one student may be mapped to > 1 sektions
    # As this is a roll-back, one would have to assign the student to one of the 
    # many sektions he/she may previously assigned to. Not a perfect solution, but the best we can do

    Student.all.each do |s|
      sektion = StudentRoster.where(:student_id => s.id).map(&:sektion_id).first
      s.update_attribute :sektion_id, sektion
    end
  end #down

end
