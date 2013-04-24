
class CompileTestpaper < Struct.new(:ws)
  def perform
    unless ws.nil?
      response = ws.compile_tex
      success = !response[:manifest].blank?
      ws.destroy unless success 
      ws.update_attribute(:job_id, 0) if success
    end
  end
end
