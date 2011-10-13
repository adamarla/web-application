
class Xml2Tex 
  def initialize( session_id )
    @root = ENV["VTA_ROOT"] 
	@src_folder = @root + "/sessions/staging/#{session_id}" 
	@xml_questions = @src_folder + "/questions.xml" 
	@xml_students = @src_folder + "/students.xml"
  end 

  def generate_QR( qsn_xml, stdnt_xml ) 
  end 
end 
