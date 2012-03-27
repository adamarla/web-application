
object false => :preview 
  code :indices do
    @scans.map(&:scan).uniq.sort
  end
