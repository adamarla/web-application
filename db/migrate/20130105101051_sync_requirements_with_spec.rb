class SyncRequirementsWithSpec < ActiveRecord::Migration
  def up
    # New requirements
    [
      ["Oops", "Factual Errors", 0],
      ["Ouch", "Inefficient line of attack", -1],
      ["Ouch", "A few silly mistakes", 0]
    ].each { |m| Requirement.new( :bottomline => m[0], :text => m[1], :weight => m[2], :other => true ).save }

  end

  def down
  end
end
