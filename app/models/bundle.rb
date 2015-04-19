# == Schema Information
#
# Table name: bundles
#
#  id         :integer         not null, primary key
#  title      :string(150)
#  package_id :integer
#  uid        :string(50)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Bundle < ActiveRecord::Base
  # attr_accessible :title, :uid

  belongs_to :package
  has_many :bundle_questions, dependent: :destroy
  has_many :questions, through: :bundle_questions

  def description?
    return self.description || "No description"
  end

  def add_questions(qids = [])
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['add_to_bundle']}"
    puts SavonClient.wsdl.endpoint
    response = SavonClient.request :wsdl, :addToBundle do
      soap.body = {
        :bundleId  => self.uid,
        :questions => Question.where(id: qids).map(&:uid)
      }
    end
    manifest = response[:add_to_bundle_response][:manifest]
    unless manifest.nil?
      qids = qids - self.questions.map(&:id)
      qids.map{ |qid|i self.questions << Question.find(qid) }
      return true
    else
      return false
    end
  end

end




