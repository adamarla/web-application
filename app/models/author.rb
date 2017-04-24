# == Schema Information
#
# Table name: authors
#
#  id         :integer         not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  is_admin   :boolean         default(FALSE)
#  first_name :string(30)
#  last_name  :string(30)
#  live       :boolean         default(FALSE)
#  email      :string(255)
#

class Author < ActiveRecord::Base
  validates :email, presence: true 
  validates :email, uniqueness: true

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

  def block_db_slots( n = 10 )
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
      q = Question.new uid:  s, author_id: self.id
      slots.delete s unless q.save # return only those slots that got created
    end
    return slots
  end

  def self.available
    where(live: true)
  end

end # of class
