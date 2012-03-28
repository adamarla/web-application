
collection @pages => :pages
  code do |p|
    pending = GradedResponse.in_quiz(@quiz.id).assigned_to(@examiner.id).with_scan.ungraded.on_page(p).map(&:scan).uniq.count
    {:id => p, :name => "page ##{p} (#{pending})"}
  end
