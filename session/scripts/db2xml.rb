
# If one wants to allow users to change question and/or 
# student selection, then one necessarily needs some way to 
# capture the current selection so that they can change it later

# The way we propose to do it is by creating an XML file with
# some initial selection drawn from the database. The user can
# then add and drop questions ( or students ). Doing so will 
# change the XML file. Once done, the contents of the XML file 
# will represent the user's final selection. 

# We then iterate over the final XML file to:
#  1. Laying out the questions - student by student - into one TeX document
#  2. Compiling the TeX document into a PDF

# That is the broad idea. And in this file, we provide proxy implementations
# of functions that would :
#  1. Generate an XML node for each selected student/question from the DB
#  2. Insert and/or remove nodes from existing XML ( => change in selection )

# This file was written when no DB was in place. Hence, it works with 
# proxy data. Whenever the DB does come into the picture, the internals 
# of the functions listed here will change. But the list of functions 
# would not. Better still, create a new class derived from this one !!

require "rexml/document" 
include REXML

class Db2Xml
  attr_reader :db_q, :db_std, :layout
  attr_reader :xml_q, :xml_std

  def initialize(session_id)
    @root = ENV["VTA_ROOT"] 

    @session_id = session_id.split('-')[1].upcase 
    @target_dir = @root + "/session/staging/#{session_id}" 
    @xml_q = @target_dir + "/db_questions.xml" 
    @xml_std = @target_dir + "/db_students.xml" 
 
    @src_dir = @root + "/session/db-test/#{session_id}" 
    @db_q = @src_dir + "/questions.db" # question XML
    @db_std = @src_dir + "/students.db"  # student XML 

    # Captures the final selection. But more importantly, the 
    # tree structure reflects the order in which questions are to be
    # laid out - with correct QR codes of course
    @layout = @target_dir + "/layout.xml"

    Dir::mkdir @target_dir unless Dir::exists? @target_dir 
  end 

  def merge_attributes(list,merge_scheme,glue = ' ')
    # List : Hash as returned by method 'gen_attribute_hash'
    #     (example) : {'id' => 'B56DF', 'first'=>'Steve', 'last'=>'Jobs'}
    # Merge Scheme : A hash. key = attribute that triggers merging, 
    # value = 2-element array. First element = array of other attributes
    # to be merged. Second element = new name for merged attribute
    #  (example) {:first => [[:last],'name'], :qr => [[:id,:marks],'QR']}
    #  NOTE: Keys that needn't be merged still need to be mentioned in 
    #        the merging scheme. (example) {:key => [[],'key'}
    # Glue : character to put between values during merging
    #  (example) Glue = 'x'
    # Return Value : A new hash with new attribute names and (merged) values
    #  (example) {'name' => 'StevexJobs', 'QR' => 'B56DFx5'}

    h = Hash.new 
    list.each {|key,value|
      key = key.to_sym
      next unless merge_scheme.has_key? key

      merge_these = merge_scheme[key][0]
      # puts "Merge_these : #{merge_these}"

      merge_these.unshift key
      # puts "Modified merge_these : #{merge_these}"
      
      merged_val = String.new  
      merge_these.each {|attr|
        merged_val += list[attr.to_s]
        merged_val += glue unless attr == merge_these.last
      }
      # puts "Merged value = #{merged_val}"

      h.store(merge_scheme[key][1], merged_val)
    }
    return h
  end 
  private:merge_attributes

  def gen_attribute_hash(token_list)
    # Input (proxy) : Array of tokens of the form [<key>:<value>]
    # Return : Hash of the form {<key> => <value>}

    h = Hash.new 
    token_list.each {|token|
      key, value = token.split(':')
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

    merge_scheme = {:id => [[],'id'], :first => [[:last], 'name'], \
                    :grade => [[:section], 'group'], :teacher => [[],'teacher']}

    xml = Element.new "student"
    h = merge_attributes(h,merge_scheme) 
    h.each {|k,v| xml.attributes[k] = v}
    return xml 
  end 
  private:gen_student_xml_node

  def gen_question_xml_node(db_data)
    # Input (proxy) : One line from .db file 
    # Input (eventually) : RoR question model object  
    # Return value : <id="{DB_ID}" marks={marks} mcq={T|F} position={in question paper}> 

    tokens = db_data.split(',')
    h = gen_attribute_hash(tokens)

    merge_scheme = {:path => [[],'path'], :id => [[:marks,:mcq,:position],'QR']}

    xml = Element.new "question"
    h = merge_attributes(h,merge_scheme,'x') 
    h.each {|k,v| xml.attributes[k] = v}
    return xml
  end 
  private:gen_question_xml_node

  ####################################################################

  def build_student_xml
    source = File.new(@db_std, 'r') 
    target = source.nil? ? nil : File.new(@xml_std,'w') 

    begin
      doc = Document.new 
      root = Element.new "students"

      doc << XMLDecl.new 
      lines = source.readlines 
      # puts lines 

      lines.each {|line| 
        line.chomp!
        xml = gen_student_xml_node(line)
        # puts xml
        root << xml 
      }
      doc << root 
      doc.write target,2 
    ensure
      source.close unless source.nil? 
      target.close unless target.nil?
    end 
  end 

  def build_question_xml
    source = File.new(@db_q, 'r') 
    target = source.nil? ? nil : File.new(@xml_q,'w') 

    begin
      doc = Document.new 
      root = Element.new "questions"

      doc << XMLDecl.new 
      lines = source.readlines 
      # puts lines 

      lines.each {|line| 
        line.chomp!
        xml = gen_question_xml_node(line) 
        # puts xml 
        root << xml 
      }
      doc << root 
      doc.write target,2 
    ensure
      source.close unless source.nil? 
      target.close unless target.nil?
    end 
  end 

  def build_layout
    begin 
      layout = File.new(@layout, 'w') 

      doms = Document.new File.open(@xml_std) 
      domq = Document.new File.open(@xml_q) 
      assignment_dom = Document.new
      
      # Prepend XML header
      assignment_dom << XMLDecl.new 

      # <assignment date="October 5,2011" id="12ab45">...</assignment>
      root = Element.new "assignment" 
      root.attributes['date'] = Time.now.strftime('%B %d, %Y')
      root.attributes['id'] = @session_id 

      # For each student ....
      doms.elements.each("students/student") { |s|
         new_student = s.clone 
         student_id = s.attributes['id']

         # OK, it makes no sense to iteratively set the same value on the
         # node. But the code in this file is just a proxy for what will be 
         # done eventually in a Rails controller. So, lets just let it be for now
         root.attributes['teacher'] = s.attributes['teacher']

         # Add each question as a child with *updated* QR codes
         domq.elements.each("questions/question") { |q|
           new_q = q.clone 
           # puts new_q
           new_qr = q.attributes['QR'] + "-#{student_id}-#{@session_id}"
           new_q.attributes['QR'] = new_qr 
           
           # Add *updated* question as a child of new_student
           new_student << new_q
         } 
         # Add new_student as a child of root
         root << new_student 
      } 

      # Time to write generated tree structure into the DOM
      assignment_dom << root 
      assignment_dom.write layout, 2

    ensure
      layout.close unless layout.nil? 
    end 
  end 

end # of class 
