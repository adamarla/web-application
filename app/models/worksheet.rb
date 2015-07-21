# == Schema Information
#
# Table name: worksheets
#
#  id                :integer         not null, primary key
#  student_id        :integer
#  exam_id           :integer
#  created_at        :datetime
#  updated_at        :datetime
#  marks             :float
#  graded            :boolean         default(FALSE)
#  honest            :integer
#  received          :boolean         default(FALSE)
#  signature         :string(255)
#  uid               :string(40)
#  job_id            :integer         default(-1)
#  billed            :boolean         default(FALSE)
#  orange_flag       :boolean
#  red_flag          :boolean
#  num_views_student :integer         default(0)
#  num_views_teacher :integer         default(0)
#

class Worksheet < ActiveRecord::Base
  belongs_to :student
  belongs_to :exam  
  has_many :tryouts, dependent: :destroy

  before_update :reset_marks_color, if: :graded_changed?
  after_create :seal

  def self.of_student(id)
    where(student_id: id)
  end

  def self.for_exam(id)
    where(exam_id: id)
  end

  def self.online 
    where(exam_id: nil)
  end

  def self.for_course(id)
    qids = Course.find(id).quiz_ids
    select{ |j| qids.include? j.exam.quiz_id }
  end

  def questions
    # returns the ordered list of question objects 
    qsel = QSelection.where(quiz_id: self.exam.quiz_id).order(:index)
    return qsel.map(&:question)
  end 

  def download_pdf?
    return nil unless self.compiled?
    return "#{Gutenberg['server']}/mint/#{self.path?}/document.pdf"
  end

  def received?(extent = :fully) # other options - :none, :partially
    # Returns true if scans have been received for some or all 
    # of the responses  

    return false unless self.billed # an unbilled worksheet could not have been received!
    return ( extent == :none ? false : true ) if self.received

    gr = Tryout.where(worksheet_id: self.id)
    n_total = gr.count 
    n_with_scan = gr.with_scan.count 
    self.update_attribute :received, true if (n_with_scan == n_total)

    ret = false 
    case extent
      when :none
        ret = (n_with_scan == 0)
      when :partially 
        ret = (n_with_scan > 0 && n_with_scan < n_total)
      when :fully 
        ret = n_with_scan == n_total 
    end
    return ret
  end

  def complete?
    return self.received? :fully
  end

  def publishable?
    # A student's answer sheet becomes publishable as soon as the 
    # last of the tryouts has been graded

    submitted = Tryout.where(worksheet_id: self.id).with_scan
    return false if submitted.count == 0
    return submitted.ungraded.count == 0
  end

  def perception? 
    # Returns either [:red | :orange | :green | :blank ] depending on 
    # what flags were set on the Tryouts

    return :red if self.red_flag
    return :orange if self.orange_flag

    m = self.tryouts.map(&:perception?)
    n = :blank 

    if m.include? :red 
      self.update_attributes red_flag: true, orange_flag: false 
      n = :red
    elsif m.include? :orange 
      self.update_attributes red_flag: false, orange_flag: true
      n = :orange
    elsif m.include? :green 
      self.update_attributes red_flag: false, orange_flag: false
      n = :green
    end 
    return n
  end 

  def spectrum?
    sbp_ids = self.exam.quiz.subparts.map(&:id)
    g = Tryout.where(worksheet_id: self.id).sort{ |m,n| sbp_ids.index(m.subpart_id) <=> sbp_ids.index(n.subpart_id) }
    return g.map(&:quality?)
  end

  def graded?( extent = :fully ) # or :partially or :none
    return (extent != :none) if self.graded

    ret = false
    if self.exam.publishable
      ret = ( extent == :none ) ? false : true
      self.update_attribute :graded, true unless (extent == :none)
    else
      gr = Tryout.where(worksheet_id: self.id)
      case extent
        when :fully 
          ret = gr.count ? (gr.graded.count == gr.count) : false 
        when :partially 
          ret = gr.count ? (gr.graded.count && (gr.graded.count < gr.count)) : false
        when :none
          ret = (gr.graded.count == 0) 
      end
      self.update_attribute(:graded, true) if (ret && (extent == :fully))
    end
    return ret
  end 

  def marks?
    return self.marks unless self.marks.nil?

    g = Tryout.where(worksheet_id: self.id)
    marks = g.graded.map(&:marks?).select{ |m| !m.nil? }.inject(:+)
    self.update_attributes(marks: marks, graded: true) if g.ungraded.count == 0
    return marks.nil? ? 0 : marks.round(2)
  end

  def graded_thus_far?
    # Returns the total (of quiz) graded till now. This number will change as more 
    # and more of the student's exam is graded 
    return self.exam.quiz.total? if self.graded?

    g = Tryout.where(worksheet_id: self.id)
    thus_far = g.graded.map(&:subpart).map(&:marks).select{ |m| !m.nil? }.inject(:+)
    return thus_far.nil? ? 0 : thus_far # will always be an integer!
  end

  def graded_thus_far_as_str
    # Returns a string of the form "marks / graded_thus_far" - where marks are whats been earned till now
    absent = Tryout.of_student(self.student_id).in_exam(self.exam_id).with_scan.count == 0
    marks = absent ? -1 : self.marks?
    return (absent ? "no scans" : "#{marks} / #{self.graded_thus_far?}")
  end

  def path?
    return "#{self.exam.quiz.uid}/#{self.uid}"
  end

  def bill
    return false if self.billed # do not bill a quiz again
    # 1. allot tryout slots for this worksheet 
    q = self.exam.quiz
    qsel = QSelection.where(quiz_id: q.id).order(:index)
    sid = self.student_id

    qsel.each do |y|
      sbp = y.question.subparts
      sbp.each do |s|
        g = self.tryouts.build student_id: sid, q_selection_id: y.id, subpart_id: s.id
        self.tryouts << g
      end
    end
    self.update_attribute :billed, true
    # 2. update account balance 
  end 

  def write
    e = self.exam
    span = e.quiz.span?
    g = Tryout.in_worksheet(self.id) 
    ids = [*1..span].map{ |pg| g.on_page(pg).map(&:id) }
    mangled_qrcs = ids.map{ |i| Worksheet.qrcode i }.join(',').upcase 

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['write_tex']}" 
    response = SavonClient.request :wsdl, :writeTex do
      soap.body = { 
        target: self.path?,
        mode: 'worksheet', 
        imports: "#{e.quiz.uid}",
        author: self.student.name, 
        wFlags: { versions: self.signature, responses: mangled_qrcs } 
      }
      end
    return response
  end 

  def compile
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['compile_tex']}" 
    response = SavonClient.request :wsdl, :compileTex do
      soap.body = { path: self.path? }
    end
    return response
  end

  def error_out
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['error_out']}" 
    response = SavonClient.request :wsdl, :errorOut do
      soap.body = { path: self.path? }
    end
    return response[:error_out_response][:manifest]
  end

  def up_view_count( audience ) # audience = :student | :teacher 
    if audience == :student 
      n = self.num_views_student 
      self.update_attribute :num_views_student, (n + 1)
    elsif audience == :teacher 
      n = self.num_views_teacher 
      self.update_attribute :num_views_teacher, (n + 1)
    end 
  end 

  def self.viewed_by(audience = :student) # audience = :student | :teacher 
    audience == :student ?  where('num_views_student > ?', 0) : where('num_views_teacher > ?', 0)
  end 

  def self.qrcode(ids = [])
    return "" if ids.blank?
    ids = ids.sort.reverse
    min = ids.pop
    suffix = ids.map{ |i| (i - min).to_s(36) }.join('.')
    return "#{min.to_s(36)}.#{suffix}"
  end

  def self.unmangle_qrcode(qrc = nil)
    return [] if qrc.blank?
    t = qrc.split('.').reverse
    base = t.pop.to_i(36)
    others = t.map{ |i| i.to_i(36) + base } 
    others.push base 
    return others
  end

  private 
      def seal 
        # Creating a worksheet does not automatically imply that it also 
        # needs to be compiled. However, versions for a questions must be set 
        n = QSelection.where(quiz_id: exam.quiz_id).count 
        sig = [*1..n].map{ rand(4) }
        update_attributes signature: sig.join(',') 
      end

      def reset_marks_color
        return true unless graded # only if graded goes from true -> false => resetting
        assign_attributes marks: nil, red_flag: nil, orange_flag: nil
      end 

end # of class
