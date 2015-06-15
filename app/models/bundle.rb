# == Schema Information
#
# Table name: bundles
#
#  id         :integer         not null, primary key
#  uid        :string(50)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  signature  :string(20)
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
    puts SavonClient.wsdl.endpoint
    response = SavonClient.request :wsdl, :addToBundle do
      soap.body = {
        bundleId: self.uid,
        questions: bqs.map{ |bq| "#{bq.question_id}|#{bq.question.uid}|#{bq.label}" }
      }
    end
    return !response[:add_to_bundle_response][:manifest].nil?
  end

  def refresh()
    self.update_zip(self.bundle_questions)
  end


end




