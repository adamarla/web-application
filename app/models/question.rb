# == Schema Information
#
# Table name: questions
#
#  id              :integer         not null, primary key
#  uid             :string(20)
#  n_picked        :integer         default(0)
#  created_at      :datetime
#  updated_at      :datetime
#  examiner_id     :integer
#  topic_id        :integer
#  suggestion_id   :integer
#  difficulty      :integer         default(1)
#  marks           :integer
#  length          :float
#  answer_key_span :integer
#  calculation_aid :integer         default(0)
#  auditor         :integer
#  audited_on      :datetime
#  available       :boolean         default(TRUE)
#

#     __:has_many____      ____:has_many___    ____:has_many__
#    |               |    |                |  |               |
#  Subject --------> Vertical -----------> Topics ---------> Questions
#    |               |  |                  |   |               |
#    |__:belongs_to__|  |___:has_many______|   |__:belongs_to__|
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

  # UID is an alphanumeric string representing the millisecond time at
  # which the folder was created in the 'vault'
  validates :uid, :uniqueness => true, :presence => true

  belongs_to :examiner
  belongs_to :topic
  belongs_to :suggestion # non-nil if question came from a teacher

  has_many :q_selections
  has_many :quizzes, :through => :q_selections
  has_many :graded_responses
  has_many :subparts, :dependent => :destroy

  has_one :video, as: :watchable

  
  def self.author(id)
    where(:examiner_id => id)
  end

  def self.difficulty(m)
    where(:difficulty => m)
  end

  def self.on_topic(m)
    where(:topic_id => m)
  end

  def self.available
    where(:available => true)
  end

  def self.audited
    where{ audited_on != nil }
  end 

  def self.unaudited
    where{ audited_on == nil }
  end

  def self.broadly_on(m)
    where(:topic_id => Vertical.find(m).topic_ids)
  end

  def self.tagged
    where('topic_id IS NOT NULL')
  end

  def self.untagged
    where('topic_id IS NULL')
  end

  def self.without_video
    select{ |m| m.video.nil? }
  end

  def self.with_video
    select{ |m| !m.video.nil? }
  end

  def self.needs_graphing_calculator
    where(:calculation_aid => 2)
  end

  def self.needs_log_tables
    where(:calculation_aid => 3)
  end

  def self.needs_scientific_calculator
    where(:calculation_aid => 1)
  end

  def self.needs_calculation_aid
    where('calculation_aid <> ?', 0)
  end

  def self.standalone
    select{ |m| m.num_parts? == 0 }
  end

  def self.order_by_marks
    select{ |m| m.marks? > 0 }.sort{ |m,n| m.marks? <=> n.marks? }
  end

  def simple_uid
    return "#{self.topic_id}-#{self.id}"
  end
  
  def ticker?
    unless self.topic_id.nil?
      return "#{self.topic.name} (#{self.marks?} points)"
    else
      return self.suggestion_id.nil? ? "" : "#{self.suggestion.signature}"
    end
  end

  def mcq? 
    mcq = Subpart.where(:question_id => self.id).map(&:mcq).inject(:&)
    return mcq
  end 

  def multi_part?
    return (self.subparts.length > 1 ? true : false)
  end 

  def num_parts?
    n = self.subparts.length
    return (( n == 1) ? 0 : n)
  end 

  def marks? # total marks over all sub-parts
    return self.marks unless self.marks.nil?

    with_marks = Subpart.where(:question_id => self.id).select{ |m| !m.marks.nil? }
    return nil if with_marks.length != self.subparts.length

    total = with_marks.map(&:marks).inject(:+)
    self.update_attribute :marks, total
    return total
  end

  def length? 
    return self.length unless self.length.nil?

    subparts = Subpart.where(:question_id => self.id)
    mcqs = subparts.select{ |m| m.mcq }.count
    shorts = subparts.select{ |m| m.few_lines }.count
    halves = subparts.select{ |m| m.half_page }.count
    fulls = subparts.select{ |m| m.full_page }.count
    total = ((mcqs + shorts) * 0.25 + halves * 0.5 + fulls * 1)
    self.update_attribute :length, total
    return total
  end

  def span?
    # For multi-part questions -> returns the # of whole pages required to typeset the question
    # For standalone questions -> returns the stored length
    length = self.length?
    return (self.multi_part? ? length.ceil : length)
  end

  def span_as_str
    span = self.span?
    case span
      when 0.25 then return "0.25 PG"
      when 0.5 then return "0.5 PG"
      when 0.75 then return "0.75 PG"
      else return "#{span} PG"
    end
  end

  def answer_key_span?
    # Returns the # of pages over which the solution to this question spans. 
    # This is a number that cannot be guessed because it really depends on 
    # how the question writer wrote the solution. Moreover, this # is also 
    # different from what span? returns because there we leave known amount of 
    # blank space for a known # of subparts 

    return self.answer_key_span unless self.answer_key_span.nil?

    # Not set yet? Guess ..
    return 1 if self.num_parts? == 0

    guess = self.subparts.map{ |m| m.full_page ? 0.5 : 0.25 }
    return guess.inject(:+).ceil
  end

  def fav(teacher)
    return teacher.favourites.map(&:question_id).include? self.id
  end

  def set_filter_classes(teacher)
    # Called when list of questions is rendered for a teacher. 
    # Returns the classes to be set on the .single-line. 
    # These classes are used to filter questions 
    klass = self.fav(teacher) ? "fav" : ""
    klass += (self.video.nil? ? "" : " video")
    return klass
  end

  def preview_images(restricted = false)
    versions = restricted ? [0] : [*0..3]
    span = self.answer_key_span?
    uid = self.uid 
    list = [] 

    for vrn in versions 
      for pg in [*1..span]
        list += ["#{uid}/#{vrn}/pg-#{pg}.jpg"]
      end
    end
    return list
  end

  def edit_tex_layout(length, marks)
    if resize_subparts_list_to length.count
      breaks = page_breaks length
      length = length.map{ |m| m == 1 || m == 4 ? "mcq" : ( m == 2 ? "halfpage" : "fullpage" ) }

      SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['tag_question']}" 
      response = SavonClient.request :wsdl, :tagQuestion do  
        soap.body = { 
           :id => self.uid,
           :marks => marks,
           :length => length,
           :breaks => breaks
        }
       end # of response 

       # As long as the response does not have an error, we are good
       return response[:tag_question_response][:manifest]
    else # re-sizing failed
      return nil
    end
  end


  def update_subpart_info(lengths, marks) 
    # 'lengths' & 'marks' are arrays of equal length sent by the controller
    subparts = Subpart.where(:question_id => self.id).order(:index)
    breaks = page_breaks lengths
    nbreaks = breaks.count
    success = true

    subparts.each_with_index do |s,j|
      l = lengths[j]
      m = marks[j]
      case l
        when 0 then mcq, half, full, few_lines = false, true, false, false
        when 1 then mcq, half, full, few_lines = true, false, false, false 
        when 2 then mcq, half, full, few_lines = false, true, false, false
        when 3 then mcq, half, full, few_lines = false, false, true, false
        when 4 then mcq, half, full, few_lines = false, false, false, true
      end

      m = m == 0 ? 3 : m # if no marks are specified, then default to marks = 3
      offset = breaks.index(breaks.select{ |m| m >= j }.first)
      offset = nbreaks if offset.nil? # for subparts on the last page

      success &= s.update_attributes(:mcq => mcq, :few_lines => few_lines, :half_page => half, 
                                     :full_page => full, :marks => m, :relative_page => offset)
      break if !success
    end

    # force recomputation of question's length and total marks by setting 
    # marks and length to nil. Recomputation will happen the next time 
    # marks? or length? is called 
    self.update_attributes :length => nil, :marks => nil if success
    return success
  end

  def increment_picked_count
    n = self.n_picked 
    self.update_attribute :n_picked, n + 1
  end

=begin
  The next 2 methods were written when support for subparts was being added.
  They are to be called ONLY from within a migration file and nowhere else.

  The first takes us from question -> subpart (up) and the second reverses the process
  and takes us from subpart to question (down)
=end 
  def split_into_subparts 
    return false if self.subparts.length > 0 # if subparts exist, then transition has probably already happened
    return false if self.topic_id.nil? # ignore untagged questions. Subparts will be created during tagging

    self.resize_subparts_list_to 1
    s = self.subparts.first
    s.update_attributes :mcq => self.mcq, :half_page => self.half_page,
                        :full_page => self.full_page, :marks => self.marks, :relative_page => 0
  end

  def rebuild_from_subparts
    return false if self.subparts.length != 1
    return false if self.topic_id.nil? 

    s = self.subparts.first
    self.update_attributes :mcq => s.mcq, :half_page => s.half_page,
                        :full_page => s.full_page, :marks => s.marks,
                        :multi_correct => false, :num_parts => 0
  end

  private 
    def page_breaks(length)
      # Returns the 0-indexed array of subpart indices AFTER which a 
      # \newpage should be inserted

      return [] if self.num_parts? == 0
      l = length.map{ |m| m == 1 || m == 4 ? 0.25 : ((m == 2) ? 0.5 : 1) }
      breaks = []

      used = 0
      last = l.count - 1

      l.each_with_index do |m, index|
        used += m
        remaining = 1 - used 

        if index != last
          next_one = l[index + 1]

          if ((next_one == 1 && remaining < 0.75) ||
             (next_one == 0.5 && remaining < 0.5) || 
             (next_one == 0.25 && remaining < 0.25))
             breaks.push index
             used = 0
          end
        end
      end # each
      return breaks 
    end # of method 

    def resize_subparts_list_to( nparts ) # nparts = 0 for a stand-alone question
      # however, internally we create 1 subpart object for even a standalone question
      nparts = (nparts == 0) ? 1 : nparts 

      subparts = Subpart.where(:question_id => self.id)
      existing = subparts.length
      additional = nparts - existing
      success = true

      if additional > 0
        [*0...additional].each do |index|
          s = self.subparts.build :index => (existing + index)
          success &= s.save
          break if !success
        end
      elsif additional < 0 
        retain = subparts.slice(0, nparts)
        remove = subparts - retain
        remove.each do |s|
          success &= s.destroy 
          break if !success
        end
      end
      return success
    end # of method 

end # of class
