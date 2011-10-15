
require 'rexml/document'
include REXML

class Xml2Tex 
  def initialize( session_id )
    @root = ENV["VTA_ROOT"] 
    @session_id = session_id.split('-')[1].upcase # session-xyz -> XYZ
    @staging_dir = @root + "/session/staging/#{session_id}"
    @layout = File.open(@staging_dir + "/layout.xml", 'r') 
    @question_paper = File.open(@staging_dir + "/question_paper.tex", 'w')
    @answer_key = File.open(@staging_dir + "/answer_key.tex", 'w')
  end 

  def link_gnuplot_files
    doc = Document.new File.open(@staging_dir + "/db_questions.xml") 
    doc.elements.each("questions/question") { |q| 
      path = q.attributes['path'] # (example) : maths/math-07
      qfolder = @root + "/#{path}" # (example) : $VTA_ROOT/maths/math-07
      qtag = path.split('/')[1] # (example) : math-07

      # puts "#{path} -> #{qfolder} -> #{qtag}"
      to = "#{qfolder}/figure.gnuplot"
      link = "#{@staging_dir}/#{qtag}.gnuplot"

      if File.exists? to 
          File.symlink(to,link) unless File.exists? link
      end 
    }
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
    # First, create symbolic links within sessions folder 
    # to any required .gnuplot files
    link_gnuplot_files
    
    # Do the same for any .sk files 

    layout = Document.new @layout 

    [@question_paper, @answer_key].each_with_index { |target, i|
      # Everything until \begin{questions}
      ['preamble.tex', 'printanswers.tex', 'doc_begin.tex'].each_with_index { |file, j| 
        if j == 1 # printanswers?
          append_to_tex target, "common/#{file}" if i == 1
        else 
          append_to_tex target, "common/#{file}" 
        end 
      } 

      # Then, the questions 
      layout.elements.each("assignment/student") { |student| 
         # \DocAuthor = { student if question_paper, teacher if answer_key}
         append_to_tex target,nil,"\\DocAuthor{#{student.attributes['name']}}" if i == 0

         student.elements.each("question") { |question| 
            append_to_tex target,nil,"\\insertQR{#{question.attributes['QR']}}" if i == 0
            tex = question.attributes['path'] + '/question.tex'
            append_to_tex target, tex
         } 
         # There is no need to iterate over every student if generating the 
         # answer key. For the same set of questions, the answer key is the 
         # same for all students 
         break if i == 1

         # Otherwise, continue appending. Just make sure that page & question
         # counters are reset
         append_to_tex target,nil,"\\newpage"
         append_to_tex target,nil,"\\setcounter{question}{0}" # refer exam.cls
         append_to_tex target,nil,"\\setcounter{page}{1}" # refer exam.cls
      }
      # Now, close the document with \end{questions}\end{document} 
      append_to_tex target, "common/doc_end.tex"
      target.close unless target.nil?
    }
  end # of build_tex

  private:link_gnuplot_files
  private:append_to_tex 
end # of class
