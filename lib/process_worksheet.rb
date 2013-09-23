
class ProcessWorksheet < Struct.new(:ws, :student, :index)
  def perform
    unless ws.nil?
      response = ws.process_worksheet(student, index)
      if !response[:manifest].blank?
        ##To Do - what is to be done for a failed job? Anything?
      end
    end
  end
end
