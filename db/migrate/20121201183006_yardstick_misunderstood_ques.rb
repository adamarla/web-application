class YardstickMisunderstoodQues < ActiveRecord::Migration
  def up
    x = Yardstick.new :weight => 1, :insight => true, :bottomline => "No",
        :meaning => %q(Student seems to understand the topic - but has misunderstood or misread the question)
    x.save
  end

  def down
  end
end
