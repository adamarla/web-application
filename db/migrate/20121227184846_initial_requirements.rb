class InitialRequirements < ActiveRecord::Migration
  def up
    # Honest attempt
    [
      ["Yes", "But its blank !", 4],
      ["No", "Highly doubtful", 0],
      ["Perhaps", "But not entirely convinced", 3],
      ["Yes", "Looks good", 4]
    ].each { |m| Requirement.new( :bottomline => m[0], :text => m[1], :weight => m[2], :honest => true ).save }

    # Cogent attempt
    [ 
      ["Irrelevant", "Major issue elsewhere", -1],
      ["Hardly", "", 0],
      ["Somewhat","Line of attack fuzzy/incorrect", 1],
      ["Mostly", "",3],
      ["Yes", "", 4]
    ].each { |m| Requirement.new( :bottomline => m[0], :text => m[1], :weight => m[2], :cogent => true ).save }

    # Complete attempt
    [
      ["Irrelevant", "Major issue elsewhere", -1],
      ["Hardly", "More incomplete than complete", 0],
      ["Somewhat", "But more needed to be done", 1],
      ["Partially", "About half-way there", 2], 
      ["Mostly", "But with some loose ends", 3],
      ["Yes", "Full follow through", 4]
    ].each { |m| Requirement.new( :bottomline => m[0], :text => m[1], :weight => m[2], :complete => true ).save }

    # Other feedback 
    [
      ["Oops", "Calculation mistake(s)", 0],
      ["Oops", "Misinterpreted question", 0], 
      ["How?", "Sudden, unexplained jumps in logic", 0],
      ["Oops", "Not all loose ends tied up", 0],
      ["Oops", "Made invalid assumptions", 0],
      ["How?", "Some of it isnt Maths", 0]
    ].each { |m| Requirement.new( :bottomline => m[0], :text => m[1], :weight => m[2], :other => true ).save }
  end

  def down
  end
end
