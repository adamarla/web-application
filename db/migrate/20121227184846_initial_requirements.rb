class InitialRequirements < ActiveRecord::Migration
  def up
    # Honest attempt
    { "Its blank" => 4, 
      "No - highly doubtful" => 0, 
      "Perhaps - but not entirely convinced" => 3, 
      "Yes - looks good" => 4
    }.each { |t, w| Requirement.new( :text => t, :weight => w, :honest => true ).save }

    # Cogent attempt
    { 
      "Irrelevant" => -1,
      "Hardly" => 0,
      "Somewhat - but not much" => 1, 
      "Partially - is half-baked" => 2, 
      "Mostly" => 3, 
      "Yes" => 4
    }.each { |t,w| Requirement.new( :text => t, :weight => w, :cogent => true ).save } 

    # Complete attempt
    {
      "Irrelevant" => -1,
      "Hardly" => 0,
      "Somewhat - but not much" => 1, 
      "Partially - is half-baked" => 2, 
      "Mostly" => 3, 
      "Yes" => 4
    }.each { |t,w| Requirement.new(:text => t, :weight => w, :complete => true).save }

    # Other feedback 
    {
      "Calculation mistake(s)" => 0, 
      "Misinterpreted question" => 0, 
      "Sudden, unexplained jumps in logic" => 0, 
      "Not all loose ends tied up" => 0,
      "Made invalid assumptions" => 0,
      "Some of it is not maths" => 0
    }.each { |t,w| Requirement.new(:text => t, :weight => w, :other => true).save }
  end

  def down
  end
end
