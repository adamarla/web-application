class SplitYardstickMeaning < ActiveRecord::Migration
  def up
    # Populate the new bottomline column by breaking up the existing meaning column, like so
    Yardstick.all.each do |m|
      tokens = m.meaning.split("(").last.split(")")
      m.update_attributes :bottomline => tokens.first.strip, :meaning => tokens.last.strip
    end 
  end

  def down
    # Merge bottomline and meaning columns into one meaning column
    Yardstick.all.each do |m|
      z = "(#{m.bottomline}) #{m.meaning}"
      m.update_attribute :meaning, z
    end
  end
end
