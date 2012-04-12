# == Schema Information
#
# Table name: questions
#
#  id            :integer         not null, primary key
#  uid           :string(255)
#  attempts      :integer         default(0)
#  created_at    :datetime
#  updated_at    :datetime
#  examiner_id   :integer
#  topic_id      :integer
#  teacher_id    :integer
#  multi_part    :boolean         default(FALSE)
#  num_parts     :integer
#  difficulty    :integer         default(1)
#  marks         :integer
#  mcq           :boolean         default(FALSE)
#  multi_correct :boolean         default(FALSE)
#  half_page     :boolean         default(FALSE)
#  full_page     :boolean         default(TRUE)
#

#     __:has_many___      __:has_many___   ____:has_many__
#    |              |    |              | |               |
#  Board --------> Courses ---------> Sp.Topics ---------> Questions
#    |               |  |               | |               |
#    |__:belongs_to__|  |___:has_many___| |__:belongs_to__|
#    

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

#     __:belongs_to___     __:belongs_to___  
#    |                |   |                | 
# Question ---------> Grade ---------> Yardstick
#    |                |   |                | 
#    |__:has_many_____|   |___:has_many____| 
#    

class Question < ActiveRecord::Base
  before_save :set_mcq_if_multi_correct

  # UID is an alphanumeric string representing the millisecond time at
  # which the folder was created in the 'vault'
  validates :uid, :uniqueness => true, :presence => true
  validates :num_parts, :numericality => {:only_integer => true, :greater_than => 0}, :if => :multi_part?

  belongs_to :examiner
  belongs_to :topic
  belongs_to :teacher # non-nil if question came from a teacher

  has_many :q_selections
  has_many :quizzes, :through => :q_selections
  has_many :graded_responses
  has_many :subparts, :dependent => :destroy

  def mcq? 
    return mcq
  end 

  def multi_part?
    return multi_part
  end 

  def num_parts?
    return (num.parts.nil? ? 0 : num_parts)
  end 

  def set_mcq_if_multi_correct
    self.mcq = (self.mcq || self.multi_correct)
    return true 
    # if self.mcq results to 'false' and the 'false' is then returned, 
    # then the save operation would be aborted (needlessly)
  end

  def marks?
    return self.marks unless self.marks.nil?
    total = self.subparts.map(&:marks).inject(:+)
    self.update_attribute :marks, total
    return total
  end

  def set_length_and_marks(length, marks)
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['tag_question']}" 
    response = SavonClient.request :wsdl, :tag_question do  
      soap.body = { 
         :id => self.uid,
         :marks => marks,
         :length => length
      }
     end # of response 
     # As long as the response does not have an error, we are good
     return response[:tag_question_response][:manifest]
  end

  def resize_subparts_list_to( num_subparts ) # num_subparts = 1 for a stand-alone question
    return false if num_subparts < 1

    subparts = Subpart.where(:question_id => self.id)
    existing = subparts.length
    additional = num_subparts - existing

    if additional > 0
      [*0...additional].each do |index|
        s = self.subparts.build :relative_index => (existing + index)
        s.save
      end
    elsif additional < 0 
      retain = subparts.slice(0, num_subparts)
      remove = subparts - retain
      remove.each do |s|
        s.destroy 
      end
    end
    self.update_attribute :num_parts, num_subparts
  end # of method 

=begin
  This next method was written when support for subparts was being added.
  Its sole purpose was/is to transfer data from the parent Question to the
  newly created Subpart. As - at the time of writing - all existing tagged 
  questions were single part, this method could be called. However, it is 
  NOT for calling in the normal course. Subparts should get their data/tags 
  from the tagging process 
=end 
  def transfer_data_to_subpart 
    return false if self.subparts.length > 0 # if subparts exist, then transition has probably already happened
    return false if self.topic_id.nil? # ignore untagged questions. Subparts will be created during tagging

    self.resize_subparts_list_to 1
    s = self.subparts.first
    s.update_attributes :mcq => self.mcq, :half_page => self.half_page,
                        :full_page => self.full_page, :marks => self.marks,
                        :multi_correct => self.multi_correct, :relative_pg => 0
  end

end
