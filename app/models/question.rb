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
#  n_codices       :integer         default(0)
#  codices         :string(5)
#  potd            :boolean         default(FALSE)
#  num_potd        :integer         default(0)
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

  acts_as_taggable_on :concept

  belongs_to :examiner
  belongs_to :topic
  belongs_to :suggestion # non-nil if question came from a teacher

  has_many :q_selections
  has_many :quizzes, through: :q_selections
  has_many :tryouts
  has_many :subparts, dependent: :destroy
  has_many :revisions, dependent: :destroy

  has_many :commentaries, dependent: :destroy 
  has_many :tex_comments, through: :commentaries

  has_many :notifications, dependent: :destroy

  has_one :video, as: :watchable

  
  def self.author(id)
    where(examiner_id: id)
  end

  def self.difficulty(m)
    where(difficulty: m)
  end

  def self.on_topic(m)
    where(topic_id: m)
  end

  def self.available
    where(available: true)
  end

  def self.audited
    where{ audited_on != nil }
  end 

  def self.unaudited
    where{ audited_on == nil }
  end

  def self.broadly_on(m)
    where(topic_id: Vertical.find(m).topic_ids)
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
    where(calculation_aid: 2)
  end

  def self.needs_log_tables
    where(calculation_aid: 3)
  end

  def self.needs_scientific_calculator
    where(calculation_aid: 1)
  end

  def self.needs_calculation_aid
    where('calculation_aid <> ?', 0)
  end

  def self.standalone
    select{ |m| m.num_parts? == 0 }
  end

  def set_potd_flag 
    b_ids = BundleQuestion.where(question_id: self.id).map(&:bundle_id) # can belong to >= 1 bundle 
    unless b_ids.blank? 
      b_uids = Bundle.where(id: b_ids).map(&:uid) 
      can_be_potd = !b_uids.select{ |b| b.starts_with? "cbse"}.blank?
    end 
    self.update_attribute :potd, (can_be_potd == true)
  end 

  def tagged? 
    return self.topic_id != nil
  end

  ####################################################################
  ##              PRICING
  # The next method returns the price - in Gredits - to be charged 
  # for seeing the answer or seeing the solution. 
  # Going forward, the price could be a function of 
  #    1. type of question ( multi-part | single-part | competitive exam etc..) 
  #    2. time of year ( charge more near exam time ) 

  def price_to_see(what) # what = :answer | :solution 
    return (what == :answer ? 2 : 5)
  end 

  ##              END PRICING
  ####################################################################

  def stab_quality
    # Returns a hash representing the percentage of stabs at various 
    # quality levels for this question. 
    stabs = Stab.graded.where(question_id: self.id)
    n = stabs.count 
    ret = {} 

    [*0...7].each do |q|
      j = stabs.where(quality: q) 
      ret[q] = j.blank? ? 0 : (j.count.to_f * 100/ n).round(1) # if j is not blank, then n > 0
    end 
    return ret
  end 

  def subparts
    Subpart.where(question_id: self.id).order(:index)
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

  def has_codex?
    return self.n_codices > 2
    # anything less than 3 options is as good as not having a codex
    # => do not enable 'Show Answers' option in mobile app.
  end

  def has_answer?
    return !self.codices.blank?
  end 

  def codex_for(version)
    return nil if (version < 0 || version > 3 || self.codices.blank?)
    return "#{self.uid}/#{version}/codex.png"
  end

  def comments 
    # Returns any ** non-trivial ** comments written by any examiner, 
    # for any subpart in any quiz in which this question appeared

    # First hints, because they are non-trivial and detailed
    tex = self.hints.map(&:text) + Commentary.where(question_id: self.id).map(&:tex_comment).map(&:text) 
    return tex.uniq
  end 

  def hints
    # returns list of hints - ordered by subpart indices 
    ids = self.subpart_ids 
    hints = Hint.where(subpart_id: ids).order(:subpart_id).order(:index)
    # assuming that db-id of subpart A < db-id of subpart B
    return hints
  end 

  def mcq? 
    mcq = Subpart.where(question_id: self.id).map(&:mcq).inject(:&)
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

    with_marks = Subpart.where(question_id: self.id).select{ |m| !m.marks.nil? }
    return nil if with_marks.length != self.subparts.length

    total = with_marks.map(&:marks).inject(:+)
    self.update_attribute :marks, total
    return total
  end

  def length? 
    return self.length unless self.length.nil?

    subparts = Subpart.where(question_id: self.id)
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

  def set_filter_classes(account)
    return nil unless account.loggable_type == 'Teacher'
    # The class attributes returned from here are set on the .line 
    # and used for filtering. For example, teachers can filter 
    # for questions that have been picked, favourited ( by her ), 
    # favourited by others etc. etc.
    klass = self.fav(account.loggable) ? "fav" : ""
    klass += (self.video.nil? ? "" : " video")
    return klass
  end

  def preview_images(versions = 0)
    versions = versions.is_a?(Array) ? versions : [versions]
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
      length = length.map{ |m| m == 1 || m == 4 ? "mcq" : ( m == 2 ? "halfpage" : "fullpage" ) }

      SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['tag_question']}" 
      response = SavonClient.request :wsdl, :tagQuestion do  
        soap.body = { id: self.uid, marks: marks, length: length }
       end # of response 

       # As long as the response does not have an error, we are good
       return response[:tag_question_response][:manifest]
    else # re-sizing failed
      return nil
    end
  end


  def update_subpart_info(lengths, marks) 
    # 'lengths' & 'marks' are arrays of equal length sent by the controller
    subparts = Subpart.where(question_id: self.id).order(:index)
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
      success &= s.update_attributes mcq: mcq, few_lines: few_lines, half_page: half, full_page: full, marks: m
      break if !success
    end

    # force recomputation of question's length and total marks by setting 
    # marks and length to nil. Recomputation will happen the next time 
    # marks? or length? is called 
    self.update_attributes(length: nil, marks: nil) if success
    return success
  end

  def increment_picked_count
    n = self.n_picked 
    self.update_attribute :n_picked, n + 1
  end

  private 
    def resize_subparts_list_to( nparts ) # nparts = 0 for a stand-alone question
      # however, internally we create 1 subpart object for even a standalone question
      nparts = (nparts == 0) ? 1 : nparts 

      subparts = Subpart.where(question_id: self.id)
      existing = subparts.length
      additional = nparts - existing
      success = true

      if additional > 0
        [*0...additional].each do |index|
          s = self.subparts.build index: (existing + index)
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
