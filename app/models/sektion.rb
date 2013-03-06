# == Schema Information
#
# Table name: sektions
#
#  id         :integer         not null, primary key
#  name       :string(40)
#  created_at :datetime
#  updated_at :datetime
#  teacher_id :integer
#  uid        :string(10)
#

class Sektion < ActiveRecord::Base
  validates :name, :presence => true 

  belongs_to :teacher

  has_many :student_rosters
  has_many :students, :through => :student_rosters

  #after_update :rebuild_student_roster_pdf
  after_create :assign_uid

  def self.in_school(s)
    where(:teacher_id => Teacher.where(:school_id => s).map(&:id))
  end

  def label 
    return self.name
  end 

  def taught_by? (teacher) 
    return self.teacher_id == teacher.id
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

  def pdf
    # UNIX has problem w/ some non-word characters in filenames
    # TeX has a problem w/ most of the rest ( unless escaped ). No one has a problem
    # with the hyphen. So, we do everything to only have it in the PDF file name
    pdf_file = "#{self.name.split(/[\s\W]+/).join('-')}"
    return pdf_file 
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

    
  def rebuild_student_roster_pdf
    students = self.students.map{ |m| { :id => m.username?, :name => m.name } }
    students.push({ :id => "", :name => ""}) if students.count.odd?

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['generate_student_roster']}" 

    response = SavonClient.request :wsdl, :generateStudentRoster do  
      soap.body = {
        :school => { :id => self.school_id, :name => self.school.name },
        :group => { :id => self.id, :name => self.pdf },
        :members => students 
      }
     end # of response 
     return response.to_hash[:generate_student_roster]
  end

  def assign_uid
    return if self.teacher_id.nil?
    uid = "#{self.teacher_id.to_s(36)}-#{Time.now.seconds_since_midnight.to_i.to_s(36)}"
    uid = uid.upcase
    self.update_attribute :uid, uid
  end

  private
end
