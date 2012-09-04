class RemoveParentFolderFromScanNames < ActiveRecord::Migration
  def up
    GradedResponse.with_scan.each do |m|
      scan = m.scan.split('/').last
      m.update_attribute :scan, scan
    end
  end

  def down
    Testpaper.all.each do |t|
      prefix = "#{t.quiz_id}-#{t.id}"
      GradedResponse.in_testpaper(t.id).with_scan.each do |m|
        scan = "#{prefix}/#{m.scan}"
        m.update_attribute :scan, scan
      end
    end
  end
end
