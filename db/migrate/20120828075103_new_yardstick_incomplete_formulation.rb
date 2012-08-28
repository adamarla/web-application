class NewYardstickIncompleteFormulation < ActiveRecord::Migration
  def up
    y = Yardstick.new :weight => 2, :formulation => true,
      :meaning => %q(Some errors due to incorrect application of standard formulae.
       Could be a silly mistake, could be a gap in knowledge).sub("\n","").split(' ').join(' '),
      :bottomline => "Yes - to some extent"
    y.save
  end

  def down
  end
end
