
object false => :preview 
  code :scans do
    @calibrations.map(&:id)
  end 

  code :mcq do
    @calibrations.map{ |m| !m.mcq_id.nil? }
  end

  code :id do
    420
  end
