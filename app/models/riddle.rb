# == Schema Information
#
# Table name: riddles
#
#  id               :integer         not null, primary key
#  type             :string(50)
#  original_id      :integer
#  chapter_id       :integer
#  parent_riddle_id :integer
#  language_id      :integer         default(1)
#  difficulty       :integer         default(20)
#  num_attempted    :integer         default(0)
#  num_completed    :integer         default(0)
#  num_correct      :integer         default(0)
#  examiner_id      :integer
#  has_svgs         :boolean         default(FALSE)
#

class Riddle < ActiveRecord::Base
  belongs_to :chapter 
  belongs_to :language 
  has_one :sku, as: :stockable, dependent: :destroy 

  around_update :repackage, if: :modified?
  after_create :add_sku

  acts_as_taggable_on :skills

  def get_id 
    return (self.original_id || self.id)
  end 

  def set_skills(ids)
    return false if ids.blank?
    uids = Skill.where(id: ids).map(&:uid).join(',')
    self.skill_list = uids 
    self.save 
    self.reload
  end 

  def set_difficulty(d) 
    # Usage: set_difficulty('easy') or set_difficulty(10) 
    df = d.is_a?(String) ? Difficulty.named(d) : d 
    self.update_attribute :difficulty, df 
  end 

  def core_skills 
    # Skills belonging to the same Chapter as this Riddle and tested by it

    all = Skill.where(chapter_id: self.chapter_id).map(&:id) 
    tested = Skill.where(uid: self.skill_list).map(&:id)
    return Skill.where(id: all & tested) 
  end 

  def self.replace_skill_x_with_y(x,y) # 'x' and 'y' are strings 
    Riddle.tagged_with(x, on: :skills).each do |r| 
      r.skill_list.remove(x) 
      r.skill_list.add(y) unless y.blank?
      r.save
    end 
  end 


  private 
      def add_sku 
        prefix = self.is_a?(Question) ? "q/#{self.examiner_id}" : "snippets"
        self.create_sku path: "#{prefix}/#{self.get_id}"
      end 

      def repackage 
        yield # save happens 

        maxd = self.difficulty.round(-1) # closest multiple of 10 >= difficulty 
        mind = maxd - 10

        query = { contains: self.type, 
                  chapter_id: self.chapter_id, 
                  language_id: self.language_id, 
                  max_difficulty: maxd, 
                  min_difficulty: mind } 

        # Ensure a single Chapter-specific parcel 
        existing = Parcel.where(query) 
        Parcel.create(query) if existing.blank? 

        # A riddle could test multiple skills spanning chapters. 
        # For example, a Calculus problem could also use Trigonometry. 
        # Creating a parcel for (Calculus, Trigonometry) seems to be 
        # over-kill. Hence, we'll focus only on the chapter-specific  
        # core skills tested by this Riddle

        self.core_skills.each do |csk|
          query[:skill_id] = csk.id 
          Parcel.create(query)
        end 

        # Lastly, trigger repackaging 
        self.sku.repackage if self.has_svgs

      end # of method 

      def modified?
        return true if (self.chapter_id_changed? ||
                        self.language_id_changed? || 
                        self.has_svgs_changed? ||
                        self.skill_list_changed?) 

        return (self.is_a?(Question) && self.difficulty_changed?)
      end 

end # of class 
