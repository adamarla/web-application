# == Schema Information
#
# Table name: quizzes
#
#  id            :integer         not null, primary key
#  teacher_id    :integer
#  created_at    :datetime
#  updated_at    :datetime
#  num_questions :integer
#  name          :string(70)
#  subject_id    :integer
#  total         :integer
#  span          :integer
#  parent_id     :integer
#  job_id        :integer         default(-1)
#  uid           :string(40)
#  version       :string(10)
#  shadows       :string(255)
#

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

# When to destroy a Quiz ? 
# ------------------------
# 
# Destroying a Quiz is a massively destructive operation. If the Quiz goes, 
# then all associated data - student grades on that quiz, entries in course-pack
# etc. etc. must go too 
#
# So, here is what I think should be done. Let the teacher indicate that she 
# does not want to use a Quiz anymore. We hide the Quiz then. And if she really
# does not use it for - say, 3 months - then we really do destroy the Quiz (using a cronjob)

include GeneralQueries

class Quiz < ActiveRecord::Base
  belongs_to :teacher 

  has_many :q_selections, dependent: :destroy
  has_many :questions, through: :q_selections
  has_many :exams, dependent: :destroy

  # Quiz -> Coursework -> Milestone
  has_many :coursework 
  has_many :milestones, through: :coursework

  # Validations
  validates :teacher_id, presence: true, numericality: true
  
  after_create :seal
  after_destroy :shred_pdfs

  def total? 
    return self.total unless self.total.nil? 
    question_ids = QSelection.where(:quiz_id => self.id).map(&:question_id)
    marks = Question.where(:id => question_ids).map(&:marks?)
    total = marks.inject(:+)
    self.update_attribute :total, total
    return total
  end

  def subparts
    # Returns the ordered list of subparts 
    qsel = QSelection.where(quiz_id: self.id).order(:index)
    return qsel.map(&:question).map(&:subparts).flatten
  end

  def last_open_exam? 
    open = Exam.for_quiz(self.id).open.order(:created_at)
    return open.last
  end 

  def assign_to(sid)
    e = self.last_open_exam?
    e = self.exams.create if e.nil?
    w = e.worksheets.build student_id: sid 

    qsel = QSelection.where(quiz_id: self.id).order(:index)
    qsel.each do |y|
      sbp = y.question.subparts
      sbp.each do |s|
        g = w.graded_responses.build student_id: sid, q_selection_id: y.id, subpart_id: s.id
        w.graded_responses << g
      end
    end
    if w.save
      Delayed::Job.enqueue(CompileTex.new(w.id, w.class.name)) if e.takehome
    end
  end

  def mass_assign_to(students, publish = false)
    sk = Sektion.common_to(students.map(&:id)).last
    name = "#{sk.name} (#{Date.today.strftime('%b %Y')})"
    e = self.exams.create name: name, takehome: publish
    for s in students 
      self.assign_to s.id
    end 

    # Close this exam for further modifications if school teacher
    e.update_attribute(:open, false) unless e.quiz.teacher.online

    unless publish 
      Delayed::Job.enqueue WriteTex.new(e.id, e.class.name)
      job = Delayed::Job.enqueue CompileTex.new(e.id, e.class.name)
      e.update_attribute :job_id, job.id
      return e.id, job.id 
    else 
      return nil, nil # no compilation required 
    end
  end

  def preview_images(restricted = false)
    path = self.path?
    return [*1..self.span?].map{ |pg| "#{path}/pg-#{pg}.jpg" }
  end

  def teacher 
    Teacher.find self.teacher_id
  end 

  def span?
    return self.span unless self.span.nil?

    last = QSelection.where(quiz_id: self.id).order(:index).last.end_page
    self.update_attribute :span, last
    return last
  end

  def lay_it_out(qids = [])
=begin
    This method defines as much of the layout as can be done reliably
    and cleanly here. It does *not* calculate shadows as for doing that 
    one needs to see not just a questions predecessors on a page 
    but also its successors

    'qids' is an array of question_ids. If its NOT blank, then it means 
    that the passed questions have to be laid out in the order given 
    in the array. Do NOT count on there being too many sanity checks on 
    qids in the code below

    Passing qids is highly NOT recommended. Do this only if you know 
    what you are doing
=end
    questions = qids.blank? ? self.questions.sort{ |m,n| m.length? <=> n.length? } : 
                              Question.where(id: qids).sort{ |m,n| qids.index(m.id) <=> qids.index(n.id) }

    qsel = QSelection.where(quiz_id: self.id)
    currpg = 1
    space_left = 1
    page_breaks = [] # stores the 'curr_subparts' after which page-breaks must be inserted
    version_triggers = []

    # Shadow Calculations
    sbp_on_curr_page = [] 
    shadows = nil

    abs_sbp_index = 0 # 0-indexed to be in-sync with what \setPageBreaks expects in TeX 

    for abs_ques_index in [*1..questions.count]
      curr_ques = questions[abs_ques_index - 1]  
      curr_qsel = qsel.where(question_id: curr_ques.id).first
      next if curr_qsel.nil?
      #curr_qsel.update_attributes start_page: currpg, index: abs_ques_index

      sbp = curr_ques.subparts.order(:index)
      n_sbp = sbp.count 
      multipart = sbp.count > 1
      brks_wthn = []

      for rel_sbp_index in [*0...n_sbp]
        curr_sbp = sbp[rel_sbp_index]
        required = curr_sbp.length?
        fits = (required <= space_left) || (required == 1 && space_left >= 0.5)
        unless fits  
          # First, update shadow information for sub-parts that were fitting until now
          total = sbp_on_curr_page.map(&:length?).inject(:+)
          spans_last_pg = sbp_on_curr_page.map{ |l| ((l.length? / total) * 100).to_i }
          shadows_last_pg = [] 

          spans_last_pg.each_with_index do |i,j|
            shadows_last_pg[j] = j > 0 ? spans_last_pg[0..j-1].inject(:+) : 0 
          end
          shadows_last_pg = shadows_last_pg.map(&:to_s).join(',')
          shadows = shadows.blank? ? shadows_last_pg : "#{shadows},#{shadows_last_pg}"

          # Then, move onto processing this one that did not fit
          sbp_on_curr_page.clear 
          sbp_on_curr_page.push curr_sbp

          currpg += 1
          space_left = 1 - required
          page_breaks.push(abs_sbp_index - 1)
          
          if multipart
            brks_wthn.push(rel_sbp_index - 1) unless rel_sbp_index == 0
          end
        else 
          sbp_on_curr_page.push curr_sbp
          space_left -= required 
        end

        abs_sbp_index += 1
        curr_qsel.update_attributes(start_page: currpg, index: abs_ques_index) if rel_sbp_index == 0
      end # of laying out subparts 

      version_triggers.push(abs_sbp_index - 1) # the last subpart, now that we are moving to next question
      pb = brks_wthn.blank? ? nil : brks_wthn.map(&:to_s).join(',')
      curr_qsel.update_attributes page_breaks: pb, end_page: currpg

    end # of laying questions

    self.update_attribute :shadows, shadows
    return page_breaks, version_triggers
  end

  def shred_pdfs
    # Going forward, this method would issue a Savon request to the
    # 'printing-press' asking it to delete PDFs of exams generated
    # for this Quiz - both composite & per-student 
    return true
  end

  def pending_scans(examiner, page)
    @pending = GradedResponse.ungraded.with_scan.in_quiz(self.id).assigned_to(examiner).on_page(page)
    @pending = @pending.sort{ |m,n| m.index? <=> n.index? }

    @scans = @pending.map(&:scan).uniq.sort
    @students = Student.where( :id => @pending.map(&:student_id).uniq )
    return @students, @pending, @scans
  end

  def children?
    return Quiz.where(parent_id: self.id)
  end 

  def clone(tid = nil)
    # Cloning is done IF: 
    #   1. A quiz cannot be edited in place because worksheets have been 
    #      made for it already 
    #   2. One teacher(self) shares a quiz with another teacher(tid). The clone
    #      should therefore rightly belong to the assignee 

    qids = QSelection.where(quiz_id: self.id).map(&:question_id)

    if tid.nil? # teacher editing her own quiz 
      t = self.teacher_id 
      n = nil
      pid = self.id
    else # teacher sharing quiz with someone else
      t = tid 
      n = self.name
      pid = nil 
    end

    c = Quiz.create teacher_id: t, question_ids: qids, num_questions: qids.count, parent_id: pid, name: n
    return c
  end

  def remove_questions(question_ids)
    return self.add_remove_questions question_ids, false
  end

  def add_questions(question_ids)
    return self.add_remove_questions question_ids, true 
  end

  def add_remove_questions(question_ids, add = false)
    return false if question_ids.count == 0
    title = "#{question_ids.count} question(s) #{add ? 'added' : 'removed'}"
    editable = self.exams.count > 0 ? self.clone  : self

    current = QSelection.where(quiz_id: editable.id).map(&:question_id)
    final = add ? (current + question_ids).uniq : (current - question_ids).uniq
    editable.question_ids = final 

    editable.recompile # another recompilation
    eta = minutes_to_completion editable.job_id 
    msg = "PDF will be ready within #{eta} minute(s)"
    return title, msg
  end

  def path?
    return self.uid
  end

  def write 
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['write_tex']}" 
    pb, vt = self.lay_it_out 
    pbreaks = pb.join(',')
    vtriggers = vt.join(',')

    # Write TeX for the quiz 
    response = SavonClient.request :wsdl, :writeTex do
      soap.body = { 
        target: self.path?, 
        mode: 'quiz', 
        imports: QSelection.where(quiz_id: self.id).order(:index).map(&:question).map(&:uid),
        author: self.teacher.name, 
        qFlags: { title: self.latex_safe_name, pageBreaks: pbreaks, versionTriggers: vtriggers }
      }
    end

    return response unless response[:error].blank? # no error => next step

    # And for a sample worksheet that has no reference in the DB 
    zeroes = Array.new(self.num_questions, 0).join(',') 
    qrcs = Array.new(self.span?, 'Sample').join(',') 

    response = SavonClient.request :wsdl, :writeTex do
      soap.body = { 
        target: "#{self.path?}/sample",
        mode: 'worksheet',
        imports: self.path?,
        author: ['Leonhard Euler', 'Karl Gauss', 'Isaac Newton', 'Srinivas Ramanujan', 'Pierre Fermat'].sample,
        wFlags: { versions: zeroes, responses: qrcs } 
      }
    end
    return response
  end 

  def compile 
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['compile_tex']}" 
    response = SavonClient.request :wsdl, :compileTex do
      soap.body = { path: self.path? }
    end

    return response unless response[:error].blank?
    response = SavonClient.request :wsdl, :compileTex do 
      soap.body = { path: "#{self.path?}/sample" }
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

  def version?
    return self.version unless self.version.nil?

    if self.parent_id.nil?
      version = "1" 
    else
      parent = Quiz.find self.parent_id
      siblings = Quiz.where(parent_id: self.parent_id).order(:created_at)
      idx = siblings.index(self) + 1
      version = "#{parent.version?}.#{idx}"
    end
    self.update_attribute :version, version
    return version
  end

  def adam?
    # The first version of the quiz from which this and other versions were made
    return (self.parent_id.nil? ? self : Quiz.find(self.parent_id).adam?) 
  end

  public # Change to private after transitioning old quizzes to new mint/ structure 
      def seal
        uid = self.uid.nil? ? "q/#{rand(999)}/#{self.id.to_s(36)}" : self.uid

        if self.name.nil?
          version = self.version?
          base = self.adam?.name.titleize
          name = (version == "1") ? base : "#{base} (ver. #{version})"
        else 
          name = self.name 
        end

        self.update_attributes uid: uid, name: name
        Delayed::Job.enqueue WriteTex.new(self.id, self.class.name)
        job = Delayed::Job.enqueue CompileTex.new(self.id, self.class.name)
        self.update_attribute :job_id, job.id
      end 

      def recompile
        # Set pages on all responses to nil so that they can be recomputed -
        # based on the changed layout (problem?) - in the next call to GradedResponse::page?
        GradedResponse.in_quiz(self.id).each do |g|
          g.update_attribute :page, nil
        end

        self.update_attributes span: nil, total: nil
        self.seal # triggers quiz recompilation

        self.exams.where(takehome: false).each do |e|
          e.seal if e.uid.nil?
          e.worksheets.each do |w|
            w.seal if w.uid.nil?
            Delayed::Job.enqueue WriteTex.new(w.id, w.class.name)
          end
          Delayed::Job.enqueue WriteTex.new(e.id, e.class.name)
          Delayed::Job.enqueue CompileTex.new(e.id, e.class.name)
        end
        return true
      end

end # of class

