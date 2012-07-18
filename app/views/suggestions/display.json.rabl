
object @suggestion => :preview
  attributes :id
  node :scans do |s|
    ["0-" + s.signature + "-1-1"]
  end
