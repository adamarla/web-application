# == Schema Information
#
# Table name: quizzes
#
#  id                    :integer         not null, primary key
#  teacher_id            :integer
#  created_at            :datetime
#  updated_at            :datetime
#  num_questions         :integer
#  name                  :string(70)
#  subject_id            :integer
#  total                 :integer
#  span                  :integer
#  parent_id             :integer
#  job_id                :integer         default(-1)
#  uid                   :string(40)
#  version               :string(10)
#  shadows               :string(255)
#  page_breaks_after     :string(255)
#  switch_versions_after :string(255)
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
    past = Exam.for_quiz(self.id).open
    last = past.blank? ? nil : past.order(:created_at).last

    if self.teacher.indie 
      if last.nil?
        renew = true 
      else
        today = Date.today 
        created_at = last.created_at 
        renew = ( today.month != created_at.month || today.year != created_at.year )
      end 
      if renew
        last.update_attribute(:open, false) unless last.nil?
        last = self.exams.create 
      end
    end 
    return last # guaranteed to be non-null either by here or by mass_assign_to
  end


=begin
    
    Individual worksheets!!

    take_home?      indie?      implies     write?        compile?
    ----------      ------      --------    ------        --------
       no             no        in-class      full           no
       no             yes       non-sense      -             -
       yes            no        takehome       no           yes
       yes            yes       takehome       no           no 
=end

  def assign_to(sid, take_home = false)
    e = self.last_open_exam?
    w = e.worksheets.create student_id: sid 

    indie = self.teacher.indie 
    w.bill unless indie # for indie quizzes, block slots only on payment

    unless take_home 
      Delayed::Job.enqueue WriteTex.new(w.id, w.class.name)
      job = Delayed::Job.enqueue(CompileTex.new(w.id, w.class.name))
      w.update_attribute(:job_id, job.id) if indie
    else 
      Mailbot.delay.quiz_assigned(w.id)
    end
    return w
  end

  # 'mass_assign_to' makes sense only in the institutional offering. Its what 
  # we did first. Has no relevance in the individual offering

  def mass_assign_to(students, take_home = false)
    indie = self.teacher.indie
    return nil,nil if indie # no mass-assignment for indie teachers

    sk = Sektion.common_to(students.map(&:id)).last
    name = "#{sk.name}_#{Date.today.strftime('%b %Y')}"
    e = self.exams.create name: name, takehome: take_home

    for s in students 
      w = self.assign_to(s.id, take_home)
    end 

    # Close this exam for further modifications if school teacher
    e.update_attribute(:open, false) 

    unless take_home 
      Delayed::Job.enqueue WriteTex.new(e.id, e.class.name)
      job = Delayed::Job.enqueue CompileTex.new(e.id, e.class.name)
      e.update_attribute :job_id, job.id
      return e.id, job.id 
    else 
      return e.id, nil # no compilation required 
    end
  end

  def preview_images
    path = self.path?
    return [*1..self.span?].map{ |pg| "#{path}/pg-#{pg}.jpg" }
  end

  def teacher 
    Teacher.find self.teacher_id
  end 

  def span?
    return self.span unless self.span.nil?
    est = self.questions.map(&:length?).inject(:+).ceil
    self.update_attribute :span, est
    return est
=begin
    # The start_page and end_page stored in QSelection is really for worksheets 
    # However, for quizzes with their solutions, the algo for calculating span? should be different 

    last = QSelection.where(quiz_id: self.id).order(:index).last.end_page
    self.update_attribute :span, last
    return last
=end
  end

  def pages?
    return self.span?
  end

  def shred_pdfs
    # Going forward, this method would issue a Savon request to the
    # 'printing-press' asking it to delete PDFs of exams generated
    # for this Quiz - both composite & per-student 
    return true
  end

  def pending_scans(examiner, page)
    @pending = Tryout.ungraded.with_scan.in_quiz(self.id).assigned_to(examiner).on_page(page)
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
    else # teacher sharing quiz with someone else. Take care of demo quizzes
      t = tid 
      n = self.name
      pid = PREFAB_QUIZ_IDS.include?(self.id) ? nil : self.id 
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

    current = QSelection.where(quiz_id: self.id).map(&:question_id)
    final = add ? (current + question_ids).uniq : (current - question_ids).uniq
    if final.blank?
      title = "Empty quiz not allowed!" 
      msg = "Going to do nothing. If you want to remove all existing questions, then add some others first" 
      return title, msg
    end

    editable = self.exams.count > 0 ? self.clone  : self
    if editable == self
      qids = Question.where(id: final).sort{ |m,n| m.length? <=> n.length? }.map(&:id)
      editable.recompile(qids) # another recompilation
    end

    eta = minutes_to_completion editable.job_id 
    msg = "PDF will be ready within #{eta} minute(s)"
    return title, msg
  end

  def path?
    return self.uid
  end

  def laid_out?
    return !(self.page_breaks_after.blank? || self.switch_versions_after.blank?)
  end

  def write
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['write_tex']}" 

    # Write TeX for the quiz 
    response = SavonClient.request :wsdl, :writeTex do
      soap.body = { 
        target: self.path?, 
        mode: 'quiz', 
        imports: QSelection.where(quiz_id: self.id).order(:index).map(&:question).map(&:uid),
        author: self.teacher.name, 
        qFlags: { 
                  title: self.latex_safe_name, 
                  pageBreaks: self.page_breaks_after, 
                  versionTriggers: self.switch_versions_after 
                }
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

  def recompile(qids = [])
    # Set pages on all responses to nil so that they can be recomputed -
    # based on the changed layout (problem?) - in the next call to Tryout::page?

    proceed = qids.blank? ? (self.laid_out? ? false : true) : true
    return false unless proceed

    Tryout.in_quiz(self.id).each do |g|
      g.update_attribute :page, nil
    end

    self.update_attributes span: nil, total: nil
    self.seal qids # triggers quiz recompilation - if needed

    self.exams.where(takehome: false).each do |e|
      e.worksheets.each do |w|
        w.uid.nil? ? w.seal : Delayed::Job.enqueue(WriteTex.new(w.id, w.class.name)) 
        # If quiz layout has changed, then the quiz's skel file would have changed too.
        # In which case, the worksheets must be re-written using the new skel
      end
      # And if the skel files of worksheets have changed, then 
      # exams must be re-written to reflect the new quiz layout 
      e.seal if e.uid.nil?
      Delayed::Job.enqueue WriteTex.new(e.id, e.class.name)
      Delayed::Job.enqueue CompileTex.new(e.id, e.class.name)
    end
    return true
  end

  def download_pdf?
    return nil unless self.compiled?
    return "#{Gutenberg['server']}/mint/#{self.path?}/document.pdf"
  end

#################################################################

  public
      def seal(qids = [])
        if self.name.nil?
          version = self.version?
          base = self.adam?.name.titleize
          name = (version == "1") ? base : "#{base} (ver. #{version})"
        else 
          name = self.name.titleize
        end

        self.update_attribute :name, name
        self.lay_it_out(qids) 

        Delayed::Job.enqueue WriteTex.new(self.id, self.class.name)
        job = Delayed::Job.enqueue CompileTex.new(self.id, self.class.name)
        self.update_attribute :job_id, job.id
      end 

      def shadows_if(sbp_on_pg)
        total = sbp_on_pg.map(&:length?).inject(:+)
        spans_last_pg = sbp_on_pg.map{ |l| ((l.length? / total) * 100).to_i }
        shadows_last_pg = [] 

        spans_last_pg.each_with_index do |i,j|
          shadows_last_pg[j] = j > 0 ? spans_last_pg[0..j-1].inject(:+) : 0 
        end
        shadows_last_pg = shadows_last_pg.map(&:to_s).join(',')
        return shadows_last_pg 
      end

#################################################################

  protected 
      def lay_it_out(qids = [])
        # 'qids' is an array of question_ids. If its NOT blank, then it means 
        # that the passed questions have to be laid out in the order given 
        # in the array. Do NOT count on there being too many sanity checks on 
        # qids in the code below

        # Passing qids is highly NOT recommended. Do this only if you know 
        # what you are doing
        
        questions = qids.blank? ? self.questions.sort{ |m,n| m.length? <=> n.length? } : 
                                  Question.where(id: qids).sort{ |m,n| qids.index(m.id) <=> qids.index(n.id) }
        self.question_ids = questions.map(&:id)
        self.update_attribute :num_questions, questions.count

        # Counters 
        curr_pg = 1 
        curr_q = 1

        # Evaluated values
        space_left = 1
        shadows = nil

        # Arrays 
        break_before = [] # subpart objects
        switch_versions_after = [] # subpart objects
        sbp_on_curr_page = [] # subpart objects
        qsel = QSelection.where(quiz_id: self.id)

        for q in questions
          curr_s = qsel.where(question_id: q.id).first
          next if curr_s.nil?

          q_index = questions.index(q) + 1 # 1-indexed
          sb_parts = curr_s.question.subparts 
          for curr_sbp in sb_parts
            index = sb_parts.index curr_sbp
            required = curr_sbp.length?
            fits = (required <= space_left) || (required == 1 && space_left >= 0.5)

            if fits
              sbp_on_curr_page.push(curr_sbp)
              space_left -= required
            else
              shadows_last_pg = self.shadows_if(sbp_on_curr_page)
              shadows = shadows.blank? ? shadows_last_pg : "#{shadows},#{shadows_last_pg}"
              break_before.push(curr_sbp)
              # Then, move onto processing this one that did not fit
              sbp_on_curr_page.clear 
              sbp_on_curr_page.push(curr_sbp)
              curr_pg += 1
              space_left = 1 - required
            end
            curr_s.update_attributes(start_page: curr_pg, index: curr_q) if index == 0
          end # laying out subparts

          curr_q += 1
          curr_s.update_attributes(end_page: curr_pg)
          switch_versions_after.push(sb_parts.last)

        end # laying out questions

        # Ensure that shadow information for last laid-out subparts is also captured
        unless sbp_on_curr_page.blank?
          shadows_last_pg = self.shadows_if sbp_on_curr_page
          shadows = shadows.blank? ? shadows_last_pg : "#{shadows},#{shadows_last_pg}"
        end
        # Collect page-break and version triggering information
        all_sbp = self.subparts
        break_after = break_before.map{ |n| all_sbp.index(n) - 1 }.join(',')
        version_on = switch_versions_after.map{ |n| all_sbp.index(n) }.join(',')
        
        self.update_attributes(shadows: shadows, page_breaks_after: break_after, switch_versions_after: version_on, span: curr_pg)
      end


end # of class

