class InsightTextRevision1 < ActiveRecord::Migration
  def up
    Yardstick.find(14).update_attribute(
      :meaning, %q(No work - or very little work - done to solve the problem. Insights missing))
    Yardstick.find(15).update_attribute(
      :meaning, %q(And what is written is mathematically incorrect))
    Yardstick.find(36).update_attribute(
      :meaning, %q(Cannot see a clearly defined line of reasoning. Not convinced insights are geneuine))
    Yardstick.find(39).update_attribute(
      :meaning, %q(Not convinced that the work done is the student's own))
    Yardstick.find(40).update_attribute(
      :meaning, %q(Student has made one or more incorrect assumptions. Subsequent work will only further a faulty line of reasoning))
    Yardstick.find(38).update_attribute(
      :meaning, %q(But the insights are rather obvious. This question is more about how equations are laid out and solved))
  end

  def down
    # no going back
  end
end
