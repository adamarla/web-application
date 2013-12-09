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
  has_many :suggestions

  # [:all] ~> [:admin]
  # [:disputed] ~> [:student]
  #attr_accessible :disputed

  def self.available
    select{ |m| m.account.active }
  end

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
			slots << manifest[:root] unless manifest.nil?

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

  def self.distribute_scans
    all = GradedResponse.unassigned.with_scan
    examiners = Examiner.select{ |e| e.account.active }.sort{ |m,n| m.updated_at <=> n.updated_at }
    n_examiners = examiners.count
    all.map(&:q_selection_id).uniq.each do |q|
      pending = all.where(q_selection_id: q) # responses to specific question in specific quiz  
      students = pending.map(&:student_id).uniq
      limit = (students / n_examiners)
      limit = limit > 20 ? limit : 20

      students.each_slice(limit).each do |j|
        assignee = examiners.shift # pop from front 

        work = pending.where(student_id: j)
        work.map{ |m| m.update_attribute :examiner_id, assignee.id }
        assignee.update_attribute :n_assigned, (assignee.n_assigned + work.count)

        examiners.push assignee # push to last
      end # over students
    end
  end

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
