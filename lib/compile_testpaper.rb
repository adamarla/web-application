
class CompileTestpaper < Struct.new(:ws, :publish)
  def perform
    unless ws.nil?
      response = ws.compile_tex(publish)
      success = !response[:manifest].blank?
      ws.destroy unless success 
      ws.update_attribute(:job_id, 0) if success
    end
  end
end
