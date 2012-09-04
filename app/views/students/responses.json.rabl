
object false => :preview 
  node(:id) { |m| @within }
  code :scans do
    @scans
  end

  code :questions do 
    @info
  end 
