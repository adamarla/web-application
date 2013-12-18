
class CompileTestpaper < Struct.new(:id)
  def perform
    ws = Testpaper.find id
    unless ws.nil?
      response = ws.compile_tex
      success = !response[:manifest].blank?

      if success 
        ws.update_attribute(:job_id, 0)
      else
        raise "[Testpaper = #{id}]: TeX compilation failed"
      end
    end
  end

  def failure(job)
    id = YAML.load(job.handler).id
    ws = Testpaper.find id 
    ws.destroy unless ws.nil?
  end

end
