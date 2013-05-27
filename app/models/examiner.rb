# == Schema Information
#
# Table name: examiners
#
#  id              :integer         not null, primary key
#  disputed        :integer         default(0)
#  created_at      :datetime
#  updated_at      :datetime
#  is_admin        :boolean         default(FALSE)
#  first_name      :string(30)
#  last_name       :string(30)
#  last_workset_on :datetime
#  n_assigned      :integer         default(0)
#  n_graded        :integer         default(0)
#

include GeneralQueries

class Examiner < ActiveRecord::Base
  has_one :account, :as => :loggable
  has_many :graded_responses

  # [:all] ~> [:admin]
  # [:disputed] ~> [:student]
  #attr_accessible :disputed

  def name 
    return self.last_name.nil? ? self.first_name : "#{self.first_name} #{self.last_name}"
  end 

  def name=(name)
    split = name.split
    last = split.count - 1
    self.first_name = split.first.humanize

    if last > 0
      middle = split[1...last].map{ |m| m.humanize[0] }.join('.')
      self.last_name = middle.empty? ? "#{split.last.humanize}" : "#{middle} #{split.last.humanize}"
    end
  end

  def block_db_slots( n = 6 )
    slots = []
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['create_question']}" 
    
    [*1..n].each do |index|
      response = SavonClient.request :wsdl, :createQuestion do
        soap.body = "#{self.id}"
      end
      manifest = response[:create_question_response][:manifest]
      unless manifest.nil?
        root = manifest[:root] 
        uid = root.split('/').last
        slots << uid
      end
      sleep 1.0/2 # sleep for 500ms
    end # of looping

    # Now, make the DB entries for the slots that were created 
    slots.each do |s|
      q = Question.new :uid => s, :examiner_id => self.id
      slots.delete s unless q.save # return only those slots that got created
    end
    return slots
  end

  def pending_workload
    return GradedResponse.where(:examiner_id => self.id).where('grade_id IS NULL').count
  end

  def self.distribute_work
=begin
  Distribution algorithm
  -----------------------
  For each quiz, find the available scans that are as yet unassigned. Note that there
  is one scan per page AND there can be >1 graded responses per page ( and therefore, scan ) 

  Distribute the scans equally amongst the available examiners. As a result, all 
  graded responses on the scan will get assigned to the examiner who gets the scan

=end
    self.distribute_standalone
    self.distribute_multipart
    self.distribute_suggestions
  end

  def self.receive_scans
=begin
    QR-Code = [7-characters for worksheet ID] + [3-characters for student] + [1-character for page]
    All encoding in base-36
=end
    
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['receive_scans']}" 
    response = SavonClient.request :wsdl, :receiveScans do
      # soap.body = "simulation"
      soap.body = {}
    end

    # manifest => { :root => ..., :image => [ ... { :id => <qr-code>.jpg } .... ]
    manifest = response[:receive_scans_response][:manifest]
    unless manifest[:image].blank?
      # All received scans - across potentially different worksheets - are stored within 
      # the same folder. The folder is time-stamped by the time at which receiveScans ran
      parent_folder = manifest[:root]

      qr_codes = manifest[:image].map{ |m| m[:id] }.select{ |m| m != "SAVON_BUG_SKIP" }
      ws_encr_codes = qr_codes.map{ |m| m[0..6] }.uniq 
      ws_ids = ws_encr_codes.map{ |m| decrypt m }

      ws_ids.each_with_index do |wid, j|
        student_ids = AnswerSheet.where(:testpaper_id => wid).map(&:student_id).sort
        scans = qr_codes.select{ |m| m[0..6] == ws_encr_codes[j] } # scans belonging to this worksheet

        responses = GradedResponse.in_testpaper(wid)

        scans.each do |scan|
          rel_index = decrypt scan[7..9]
          sid = student_ids[rel_index]
          page = scan[10].to_i(36)

          responses.of_student(sid).on_page(page).each do |m|
            m.update_attribute :scan, "#{parent_folder}/#{scan}"
            # m.update_attribute :scan, scan
            # puts "#{m.id} --> #{parent_folder}/#{scan}"
          end
        end # scans belonging to given worksheet

      end # iterating over worksheets 
      self.distribute_scans(false) # the big kahuna. Pass 'true' for debug mode
    end # unless 
  end

  def self.distribute_scans(debug = false)
    unassigned = GradedResponse.unassigned.with_scan
    ws_ids = unassigned.map(&:testpaper_id).uniq
    examiners = Examiner.where(:is_admin => true).select{ |m| m.account.active }
    n_examiners = examiners.count
    limit = 20

    ws_ids.each do |ws|
      quiz = Quiz.find(Testpaper.find(ws).quiz_id)
      layout = quiz.layout? false
      in_ws = unassigned.in_testpaper(ws).order(:student_id).order(:page)

      for page in layout
        questions = page[:question]
        num_questions = questions.count 
        pg = page[:number]
        on_page = in_ws.on_page(pg)
        student_ids = on_page.map(&:student_id).uniq

        multi_part = num_questions > 1 ? false : (Question.find(questions.first).subparts.count > 1)
        if multi_part 
          n_students = student_ids.count 
        else
          n = on_page.count
          next if n == 0
          n_students = (n / num_questions) # n % num_questions == 0. If not, then sth. wrong with receiveScan
        end
        n_reqd = (n_students / limit) + 1
        n_reqd = (n_reqd > n_examiners) ? n_examiners : n_reqd 
        per_examiner = (n_students / n_reqd) + 1
        examiners = examiners.sort{ |m,n| m.n_assigned <=> n.n_assigned }

        student_ids.each_slice(per_examiner).each_with_index do |ids, index|
          assignee = examiners[index]
          responses = on_page.select{ |m| ids.include? m.student_id }
          for r in responses
            r.update_attribute(:examiner_id, assignee.id) unless debug
          end

          if debug
            puts "#{assignee.name} --> [#{quiz.name}, ##{pg}] --> #{ids.count}"
          else
            till_now = assignee.n_assigned
            assignee.update_attribute :n_assigned, (till_now + responses.count) 
          end
        end # of iterating over slices
      end # of iterating over pages
    end # of iterating over worksheets
  end # of method

  private

    def self.distribute_suggestions
      # last_workset_on is updated ONLY when graded_responses are assigned. So, if you 
      # aren't grading, then you must typeset some questions 
      e_ids = Examiner.where(:is_admin => true).order(:last_workset_on).map(&:id)
      n = e_ids.count

      Suggestion.unassigned.each_with_index do |m, j|
        m.update_attribute :examiner_id, e_ids[j % n]
      end
    end #  of method

end # of class
