
class CompileTestpaper < Struct.new(:ws)
  def perform
    unless ws.nil?
      response = ws.compile_tex
      ws.destroy if response[:manifest].blank?
    end
  end
end
