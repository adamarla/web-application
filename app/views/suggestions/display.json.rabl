
object @suggestion => :preview
  attributes :id
  node :scans do |s|
    ["0-" + s.filesignature + "-1-1"]
  end
