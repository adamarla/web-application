
# If one wants to allow users to change question and/or 
# student selection, then one necessarily needs some way to 
# capture the current selection so that they can later change it 

# The way we propose to do it is by creating an XML file with
# some initial selection drawn from the database. The user can
# then add and drop questions ( or students ). Doing so will 
# change the XML file. Once done, the contents of the XML file 
# will represent the user's final selection. 

# We then iterate over the final XML file to:
#  1. Generate student specific QR codes for each selected question
#  2. Laying out the questions - student by student - into one TeX document
#  3. Compiling the TeX document into a PDF

# That is the broad idea. And in this file, we provide proxy implementations
# of functions that would :
#  1. Generate an XML node from DB data
#  2. Insert and/or remove nodes from existing XML ( => change in selection )

# This file was written when no DB was in place. Hence, it works with 
# proxy data. Whenever the DB does come into the picture, the internals 
# of the functions listed here will change. But the list of functions 
# would not. Better still, create a new class derived from this one !!

require "rexml/document" 
include REXML

class Db2Xml
  attr_reader :db_q

  def initialize(session_id)
    @root = ENV["VTA_ROOT"] 

	@target_dir = @root + "/session/staging/#{session_id}" 
	@xml_q = @target_dir + "/questions.xml" 
	@xml_std = @target_dir + "/students.xml" 
 
	@src_dir = @root + "/session/db-test/#{session_id}" 
	@db_q = @src_dir + "/questions.db" # question XML
	@db_std = @src_dir + "/students.db"  # student XML 

	Dir::mkdir @target_dir unless Dir::exists? @target_dir 
  end 

  def gen_attribute_hash(token_list)
    # Input (proxy) : Array of tokens of the form <key>:<value>
	# Return : Hash

	h = Hash.new 
	token_list.each {|token| \
	  key, value = token.split(':') ;\
	  h.store(key,value)
	}
	return h
  end 
  private:gen_attribute_hash

  def gen_student_xml_node(db_data)
    # Input (proxy) : One line from .db file 
    # Input (eventually) : RoR student model object  
    # Return value : <id="{DB_ID}" name="{first} {last}" group="{grade}-{section}">

	tokens = db_data.split(',')
	h = gen_attribute_hash(tokens)

	xml = Element.new "student"
	h.each {|key,value| xml.attributes[key] = value}
	return xml 
  end 
  private:gen_student_xml_node

  def gen_question_xml_node(db_data)
    # Input (proxy) : One line from .db file 
    # Input (eventually) : RoR question model object  
    # Return value : <id="{DB_ID}" marks={marks} mcq={T|F} position={in question paper}> 

	tokens = db_data.split(',')
	h = gen_attribute_hash(tokens)

	xml = Element.new "question"
	h.each {|key,value| xml.attributes[key] = value}
	return xml
  end 
  private:gen_question_xml_node

  def parse_student_db
    source = File.new(@db_std, 'r') 
	target = source.nil? ? nil : File.new(@xml_std,'w') 

	begin
	  doc = Document.new 
	  root = Element.new "students"

	  doc << XMLDecl.new 
	  lines = source.readlines 
	  puts lines 

	  lines.each {|line| \
	    line.chomp! ; \
	    xml = gen_student_xml_node(line) ; \
		puts xml ; \
	    root << xml 
	  }
	  doc << root 
	  doc.write target,2 
	ensure
	  source.close unless source.nil? 
	  target.close unless target.nil?
	end 
  end 

  def parse_question_db
    source = File.new(@db_q, 'r') 
	target = source.nil? ? nil : File.new(@xml_q,'w') 

	begin
	  doc = Document.new 
	  root = Element.new "questions"

	  doc << XMLDecl.new 
	  lines = source.readlines 
	  puts lines 

	  lines.each {|line| \
	    line.chomp! ; \
	    xml = gen_question_xml_node(line) ; \
		puts xml ; \
	    root << xml 
	  }
	  doc << root 
	  doc.write target,2 
	ensure
	  source.close unless source.nil? 
	  target.close unless target.nil?
	end 
  end 

end # of class 
