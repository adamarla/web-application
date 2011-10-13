
# If one wants to allow users to change question and/or 
# student selection, then one necessarily needs some way to 
# capture the current selection so that they can later change it 

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
  attr_reader :db_q, :db_std

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

  def merge_attributes(list,mapping,glue = ' ')
    # List : Hash as returned by method 'gen_attribute_hash'
    #     (example) : {'id' => 'B56DF', 'first'=>'Steve', 'last'=>'Jobs'}
    # Mapping : A hash. key = attribute that triggers merging, 
    # value = 2-element array. First element = array of other attributes
    # to be merged. Second element = new name for merged attribute
    #  (example) {:first => [[:last],'name'], :qr => [[:id,:marks],'QR']}
    # Glue : character to put between values during merging
    #  (example) Glue = 'x'
    # Return Value : A new hash with new attribute names and (merged) values
    #  (example) {'name' => 'StevexJobs', 'QR' => 'B56DFx5'}

    h = Hash.new 
    list.each {|key,value|
      key = key.to_sym
      next unless mapping.has_key? key

      merge_these = mapping[key][0]
      puts "Merge_these : #{merge_these}"

      merge_these.unshift key
      puts "Modified merge_these : #{merge_these}"
      
      merged_val = String.new  
      merge_these.each {|attr|
        merged_val += list[attr.to_s]
        merged_val += glue unless attr == merge_these.last
      }
      puts "Merged value = #{merged_val}"

      h.store(mapping[key][1], merged_val)
    }
    return h
  end 
  private:merge_attributes

  def gen_attribute_hash(token_list)
    # Input (proxy) : Array of tokens of the form <key>:<value>
    # Return : Hash

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

    skip_keys = [:last, :section]
    merge_keys = {:first => [[:last], 'name'], :grade => [[:section], 'group']}

    xml = Element.new "student"
    h = merge_attributes(h,merge_keys) 
    h.each {|k,v| 
      xml.attributes[k] = v
    }
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

      lines.each {|line| 
        line.chomp!
        xml = gen_student_xml_node(line)
        puts xml
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

      lines.each {|line| 
        line.chomp!
        xml = gen_question_xml_node(line) 
        puts xml 
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
