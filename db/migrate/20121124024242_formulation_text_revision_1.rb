class FormulationTextRevision1 < ActiveRecord::Migration
  def up
    Yardstick.find(20).update_attribute(
      :meaning, %q(And it doesn't matter. The bigger issue is that insights are missing - or are off by a lot))
    Yardstick.find(21).update_attribute(
      :meaning, %q(The follow-up work might be mathematically correct - even complete. But it only furthers a faulty line of reasoning))
    Yardstick.find(22).update_attribute(
      :meaning, %q(Some follow-up work shown - but a lot more needed to be done)) 
    Yardstick.find(23).update_attribute(
      :meaning, %q(An honest attempt - but with some loose ends. Tie up the loose ends to complete the solution))
  end

  def down
    # no going back
  end
end
