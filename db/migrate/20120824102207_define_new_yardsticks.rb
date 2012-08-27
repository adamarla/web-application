class DefineNewYardsticks < ActiveRecord::Migration
  def up
    insights = {
      0 => [
            "(No) The response is either blank or too sparse to capture any insights",
            "(No) And what is written is not mathematically sound"
           ], 
      1 => [
            "(No) And the approach taken will not lead to the correct answer"
           ],
      2 => [
            "(Yes, and no) Some key insights required to get to the correct answer missing" 
           ], 
      3 => [
            "(Yes) All required insights captured"
           ]
    }

    insights.each do |k,v|
      v.each do |reason|
        c = Yardstick.new :insight => true, :weight => k, :meaning => reason
        c.save
      end
    end

    formulations = { 
      0 => [
            "(No) Irrelevant in this case"
           ], 
      1 => [
            "(No) The follow up work is irrelevant because the insights are either missing or off by a lot",
            "(Yes, and no) In of itself, the follow up work might be correct. But it only furthers a faulty line of reasoning",
            "(No) The follow-up work is more incomplete than complete"
           ],
      2 => [
            "(Yes, and no) The follow up work has some errors and/or is only partially complete" 
           ],
      3 => [
            "(Yes) A systematic approach and justifications for correct reasoning are evident",
            "(Yes) But there are sudden, non-obvious jumps in logic. A little more elaboration of intermediate steps would have been nice"
           ]
    } 

    formulations.each do |k,v|
      v.each do |reason|
        c = Yardstick.new :formulation => true, :weight => k, :meaning => reason
        c.save
      end
    end

    calculations = { 
      0 => [
            "(Not important) There are other issues with the response that need to be addressed first"
           ],
      1 => [
            "(No) Some errors here and there"
           ],
      2 => [
            "(Yes) All calculations performed correctly"
           ]
    }

    calculations.each do |k,v|
      v.each do |reason|
        c = Yardstick.new :calculation => true, :weight => k, :meaning => reason
        c.save
      end
    end

=begin
    MCQ Yardsticks 
=end

    mcq_yardsticks = { 
      0 => [
            "(No) The question has not been attempted"
           ],
      1 => [
            "(No) None of the right options picked"
           ],
      2 => [
            "(Yes, and no) Some of the other correct options not picked however",
            "(Yes, and no) Some of the selected options are wrong" 
           ],
      3 => [
            "(Yes) All of the right - and none of the wrong - options picked"
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
    Yardstick.all.each do |m|
      m.destroy
    end
  end
end

