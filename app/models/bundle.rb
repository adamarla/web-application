# == Schema Information
#
# Table name: bundles
#
#  id            :integer         not null, primary key
#  uid           :string(50)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  signature     :string(20)
#  auto_download :boolean         default(FALSE)
#

class Bundle < ActiveRecord::Base
  # attr_accessible :title, :uid

  validates :uid, presence: true 
  validates :uid, uniqueness: true

  has_many :bundle_questions, dependent: :destroy
  has_many :questions, through: :bundle_questions

  def description?
    return self.description || "No description"
  end

  def update_zip(bqs)
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['add_to_bundle']}"
    # puts SavonClient.wsdl.endpoint
    response = SavonClient.request :wsdl, :addToBundle do
      soap.body = {
        bundleId: self.uid,
        questions: bqs.map{ |bq| "#{bq.question_id}|#{bq.question.uid}|#{bq.label}" }
      }
    end
    return !response[:add_to_bundle_response][:manifest].nil?
  end

  def refresh
    self.update_zip(self.bundle_questions)
  end

  def attempts(pid)
    # Returns the attempts by given student for the questions 
    # in this bundle (sorted by label).

    qids = self.bundle_questions.sort{ |a,b| a.label <=> b.label }.map(&:question_id)
    a = Attempt.where(pupil_id: pid, question_id: qids).sort{ |x,y| qids.index(x.question_id) <=> qids.index(y.question_id) }
    return a 
  end 

  def identify(attempts) 
    # Returns labels for attempts in the same order as the passed array is
    qids = attempts.map(&:question_id) 
    entries = BundleQuestion.where(bundle_id: self.id, question_id: qids).sort{ |x,y| qids.index(x.question_id) <=> qids.index(y.question_id) }
    return entries.map(&:label)
  end 

  def self.set_potd_flag(is_potd)
    bundles = Bundle.select{ |b| b.uid.starts_with? "cbse" }
    qids = BundleQuestion.where(bundle_id: bundles.map(&:id)).map(&:question_id) 
    Question.where(id: qids).each do |q| 
      q.update_attribute :potd, is_potd
    end 
  end 

end




