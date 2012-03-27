
object false => :preview 
  code :indices do
    @scans.map(&:scan).uniq
  end
