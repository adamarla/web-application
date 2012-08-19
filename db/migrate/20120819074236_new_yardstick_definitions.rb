class NewYardstickDefinitions < ActiveRecord::Migration
  def up
    desc = ["No - the response is either blank or too sparse to capture any insights",
            "No - and what is written has no mathematical basis. Suggests a gap in understanding of fundamental concepts",
            "No - the student overlooked some fundamental mathematical fact(s). He/she might find an answer, but it is guaranteed to be wrong", 
            "No - and the student will not be able to get to the right answer based on what is written"
           ]

    desc.each do |m|
      y = Yardstick.new :meaning => m, :insight => true, :weight => 1
      y.save
    end 

    desc = ["No - the follow up work is either absent or too sparse",
            "No - and that should be expected. The solution was already along the wrong lines because of missing insights",
            "No - the follow up work either has inaccuracies or is incomplete - perhaps because of gaps in knowledge"
           ]
    
    desc.each do |m|
      y = Yardstick.new :meaning => m, :formulation => true, :weight => 1
      y.save
    end 

    desc = ["Not applicable", "No - a few mistakes made"]
    desc.each do |m|
      y = Yardstick.new :meaning => m, :calculation => true, :weight => 1
      y.save
    end 

    desc = ["Yes - but not all of them. The solution requires more than one insight and the student didn't recognize one or more of them"]
    desc.each do |m|
      y = Yardstick.new :meaning => m, :insight => true, :weight => 2
      y.save
    end 

    desc = ["Yes, and no. In itself, the follow up work is correct. But it only furthers a faulty line of reasoning"]
    desc.each do |m|
      y = Yardstick.new :meaning => m, :formulation => true, :weight => 2
      y.save
    end 

    desc = ["Yes - all required insights captured"]
    desc.each do |m|
      y = Yardstick.new :meaning => m, :insight => true, :weight => 3
      y.save
    end 

    desc = ["Yes - but there are sudden, non-obvious jumps in logic. A little more elaboration of intermediate steps would lay to rest any doubts about the student's understanding"] 
    desc.each do |m|
      y = Yardstick.new :meaning => m, :formulation => true, :weight => 3
      y.save
    end 

    desc = ["Yes - a systematic approach and justifications for correct reasoning are present"]
    desc.each do |m|
      y = Yardstick.new :meaning => m, :formulation => true, :weight => 3
      y.save
    end 

    desc = ["Yes - all calculations performed correctly"]
    desc.each do |m|
      y = Yardstick.new :meaning => m, :calculation => true, :weight => 3
      y.save
    end 
  end

  def down
    Yardstick.all.each do |m|
      m.destroy
    end
  end
end
