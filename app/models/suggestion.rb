# == Schema Information
#
# Table name: suggestions
#
#  id          :integer         not null, primary key
#  teacher_id  :integer
#  examiner_id :integer
#  completed   :boolean         default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#  signature   :string(15)
#  pages       :integer         default(1)
#

class Suggestion < ActiveRecord::Base
  has_many :questions
  belongs_to :teacher  
  belongs_to :examiner

  validates :signature, uniqueness: true
  after_create :inform_examiner
  after_create :inform_teacher, if: Proc.new{ |sg| sg.teacher.account.has_email? } 

  def self.unassigned
    where(examiner_id:  nil)
  end  

  def self.assigned_to(id)
    where(examiner_id:  id)
  end

  def self.ongoing
    where(completed:  false).select{ |m| m.question_ids.count > 0 }
  end

  def self.just_in
    select{ |m| m.question_ids.count == 0 }
  end
  
  def self.completed
    where completed:  true
  end

  def self.mime_type(upload_params)
    mime = upload_params.content_type
    if mime == 'application/octet-stream'
      uploaded_file = upload_params.tempfile
      mime = `file -b --mime-type #{File.absolute_path uploaded_file}`.gsub(/\n/,"")
    end
    return mime
  end

  def self.valid_mime_type?(mime)
    matcher = ["^image", "pdf", "text/plain", "opendocument.text", "msword", "document"]
    valid = false
    extension = nil

    matcher.each_with_index do |m,j|
      valid = mime.match(/#{m}/).nil? ? false : true
      if valid
        # 01 => to-pdf -> convert 
        # 02 => run convert directly
        extension = j < 2 ? "02" : "01"
        break
      end
    end 
    return valid, extension 
  end

  def check_for_completeness
    return true if self.completed 
    untagged = Question.where(suggestion_id:  self.id).untagged 
    if untagged.count == 0
      Mailbot.delay.suggestion_typeset(self) if self.update_attribute(:completed, true)
    end
    return false
  end

  def days_since_receipt
    return (Date.today - self.created_at.to_date).to_i
  end

  def weeks_since_receipt(categorize = false)
    # categorize groups scans into one of 4 buckets that are shown in #days-since-receipt
    w = self.days_since_receipt / 7
    return (categorize ? (w > 4 ? 4 : w) : w)
  end

  def label
    self.created_at.strftime "%b %d, %Y"
  end

  def image
    return "0-#{self.teacher_id}/#{self.signature}"
  end

  def preview_images
    from = self.teacher_id
    sig = self.signature
    return [*1..self.pages].map{ |pg| "0-#{from}/#{sig}/page-#{pg}.jpeg" }
  end

  def inform_examiner
    Mailbot.delay.new_suggestion(self)
  end

  def inform_teacher
    Mailbot.delay.suggestion_received(self)
  end

end # of class
