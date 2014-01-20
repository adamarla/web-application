
# Rather than store the (serialized) object itself in the Delayed::Job 
# database, we store the type and id for two reasons: 
#   1. we store less 
#   2. Sometimes, the underlying object has been destroyed by the
#      time the code gets to the error / failure callbacks. In that 
#      case, we should get a nil object instead of an out-of-date object

class WriteTex < Struct.new(:id, :type)
  def perform
    obj = type.constantize.where(id: id).first
    resp = obj.write 
    raise "WriteTex (failed)" unless resp[:error].blank?
  end 

  def error(job, exception)
    h = YAML.load(job.handler)
    obj = h.type.constantize.where(id: h.id).first
    obj.update_attribute :job_id, WRITE_TEX_ERROR 
  end

  def failure(job)
    h = YAML.load(job.handler)
    obj = h.type.constantize.where(id: h.id).first
    unless obj.nil?
      # obj.destroy unless obj.job_id == COMPILE_TEX_ERROR # CompileTex failed. Leave the destroying to it
      resp = obj.error_out
      lnk = resp[:root].blank? ? nil : resp[:root] 
      Mailbot.delay.report_mint_error(obj, lnk) unless lnk.blank?
    end
  end

  def success(job)
    h = YAML.load(job.handler)
    obj = h.type.constantize.where(id: h.id).first
    obj.update_attribute :job_id, 0
  end

end 