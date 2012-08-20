class DefineNewMcqYardsticks < ActiveRecord::Migration
  def up
    mcq_yardsticks = { 
      0 => [
            "No attempt"
           ],
      1 => [
            "(Incorrect) None of the right options picked"
           ],
      2 => [
            "(Partially correct) Some of the other correct options not picked however",
            "(Partially correct) Some of the selected options are wrong" 
           ],
      3 => [
            "(Correct) All of the right - and none of the wrong - options picked"
           ]
    } 

    mcq_yardsticks.each do |k,v|
      v.each do |reason|
        y = Yardstick.new :mcq => true, :weight => k, :meaning => reason
        y.save
      end
    end 

  end

  def down
    Yardstick.mcqs.each do |m|
      m.destroy
    end 
  end
end
