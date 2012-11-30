class NewYardsticksReverseEngg < ActiveRecord::Migration
  def up
    x = Yardstick.new :weight => 1, :insight => true, :bottomline => "No",
        :meaning => %q(Student has used the final result to prove original hypothesis - rather than work his/her way through to the result)
    y = Yardstick.new :weight => 2, :formulation => true, :bottomline => "Not important",
        :meaning => %q(The work done is not in the spirit of the question)

    x.save
    y.save
  end

  def down
  end
end
