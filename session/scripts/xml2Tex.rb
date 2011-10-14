
require 'rexml/document'
include REXML

class Xml2Tex 
  def initialize( session_id )
    @root = ENV["VTA_ROOT"] 
    @session_id = session_id.split('-')[1].upcase
    @staging_dir = @root + "/session/staging/#{session_id}"
    @source = File.open(@staging_dir + "/question_paper.xml", 'r') 
    @question_paper = File.open(@staging_dir + "/question_paper.tex", 'w')
    @answer_key = File.open(@staging_dir + "/answer_key.tex", 'w')
  end 

  def append_to_tex(target_file, relative_path = nil, text = nil) # relative to @root
    # It is assumed that the target_file is open for appending.   
    begin 
      src = File.open(@root + "/#{relative_path}", 'r') unless relative_path.nil?
      buffer = src.nil? ? text : src.read(src.size)
      target_file << buffer unless buffer.nil?
    ensure
      src.close unless src.nil?
    end 
  end 

  def build_tex 
    ['common/preamble.tex','common/doc_begin.tex'].each_with_index { |f, index|
      append_to_tex @question_paper, f
      append_to_tex @answer_key, f
      append_to_tex @answer_key, nil, "\\printanswers" if index == 0
    }

    # Now, for each student, append questions with their unique QR codes
    doc = Document.new @source 
    doc.elements.each("assignment/student") { |s|
      finish_build = false 

      s.elements.each("question") { |q|
        # First, insert the question specific QR code
        append_to_tex @question_paper,nil,"\\insertQR{#{q.attributes['QR']}}"

        # Then, insert question.tex from the question-bank
        question = q.attributes['path'] + '/question.tex'
        [@question_paper, @answer_key].each { |f| 
           append_to_tex f, question
        } 
      } 

      [@question_paper, @answer_key].each_with_index { |f, index| 
        # Insert a new page after every student 
        append_to_tex f,nil, "\\newpage"
        # Reset the page and question counters 
        append_to_tex f,nil, "\\setcounter{question}{0}" # refer exam.cls
        append_to_tex f,nil, "\\setcounter{page}{1}" # refer exam.cls
        # Change header contents - namely - the student's name 

        # There is no need to iterate over all students when generating
        # the answer key. For the same questions, the answers would be the same. 
        # Hence, if generating the answer key, break after finishing with the
        # first student 
        finish_build = index == 1 ? true : false
        break if finish_build 
      } 
      break if finish_build
    }

    # Finally, close the document
    [@question_paper, @answer_key].each { |f|
      append_to_tex f, "common/doc_end.tex"  
    } 

    # And the file handles...
    @question_paper.close unless @question_paper.nil? 
    @answer_key.close unless @answer_key.nil?
  end 
end # of class
