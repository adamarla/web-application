# == Schema Information
#
# Table name: study_groups
#
#  id         :integer         not null, primary key
#  school_id  :integer
#  klass      :integer
#  section    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class StudyGroup < ActiveRecord::Base
  validates :klass, :presence => true 
  validates :section, :presence => true 

  validates :section, :uniqueness => { :scope => [:klass, :school_id] } 

  belongs_to :school
  has_many :students

  has_many :faculty_rosters
  has_many :teachers, :through => :faculty_rosters

  def name 
    return "#{self.klass.to_s}-#{self.section} (#{self.students.count})"
  end 

  def taught_by? (teacher) 
    !( FacultyRoster.where(:study_group_id => self.id, :teacher_id => teacher.id).empty? )
  end 

  def update_student_list ( student_list ) 
    # student_list is a hash of the form : { 1 => true, 2 => false, 3 => true ... }
    # and is actually equal to params[:checked]

    student_list.each { |student_id, assign| 
      student = Student.find student_id 
      if assign 
        student.update_attribute(:study_group_id, self.id) 
      else 
        student.update_attribute(:study_group_id, nil) if student.study_group_id == self.id 
      end 
    } 
  end 

end
