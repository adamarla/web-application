module ApplicationHelper

  def html_attrs(lang = 'en-US')
    {:xmlns => "http://www.w3.org/1999/xhtml", 'xml:lang' => lang, :lang => lang}
  end 

  def trojan_horse_for(name) 
    # creates a hidden <input> field inside a form, pre-populated - 
    # usually by the 'marker' attribute of the containing DOM element
    #   <input type="text" class="hidden" name="student[marker]"

    tag :input, :type => :text, :class => :hidden, :name => "#{name.to_s}[marker]", :trojan => true
  end 

  def make_link (type, options = {})
    # 'dynamic' links are those that load tables and controls on click. Non-dynamic links, 
    # like for logout and login, don't

    name = options[:for].to_s 
    href = options[:href] || '#' 
    with = options[:with] 

    if type == :main
      singular = name.singularize
      plural = name.pluralize
      dynamic = options[:dynamic].nil? ? true : options[:dynamic] 
      class_attr = 'main-link'
      label = name 

      if dynamic
         # for main-links, the side-panel is fixed. Anything else specified 
         # using :with is ignored   

         panels = with.blank? ? {} : with[:panels] 
         panels = panels.merge( { :side => "##{plural}-summary" } )
         if (with.blank? || with[:controls].blank?) 
           controls = "##{singular}-controls"
         else 
           controls = with[:controls]
         end 
      else 
         panels = {} 
         controls = nil 
      end 
    elsif type == :minor 
      class_attr = 'minor-link'
      panels = with.blank? ? {} : with.delete(:panels) 
      controls = with.blank? ? nil : with.delete(:controls)
      label = options[:label].blank? ? name : options[:label]
    end 
    
    side = panels[:side]
    middle = panels[:middle]
    right = panels[:right]
    wide = panels[:wide]

    link = link_to label.humanize, href, :id => "#{name}-link", :class => class_attr, 
                               :side => side, :middle => middle, :right => right, 
                               :wide => wide, 'load-controls' => controls

    return content_tag(:li, link, :id => "#{name}-anchor") 
  end 

  def main_link(options = {}) 
    make_link :main, options 
  end 

  def minor_link(options = {}) 
    make_link :minor, options 
  end 

=begin
   Usage Example : drop_down_menu_for :subjects, :disabled => true, :name => 'subjects[1]'
   Options : 
         :disabled => [true | false] 
         :name => < string > (default = :criterion) 
         :include_blank => [true | false]
         :slider => [true | false] (Sets attribute 'slider=true' attribute on the dropdown) 
=end 

  def drop_down_menu_for (sth, options = {}) 
    collection = nil 

    plural = (sth == :difficulty) ? sth : sth.to_s.pluralize.to_sym
    singular = plural.to_s.singularize

    disabled = options[:disabled].nil? ? false : options[:disabled]
    include_blank = options[:include_blank].nil? ? true : options[:include_blank]
    prefix = options[:name].nil? ? :criterion : options[:name]
    slider = options[:slider].nil? ? false : ((plural == :percentages) && options[:slider]) 

    case plural
      when :boards 
        collection = Board.all 
      when :klasses 
        collection = [*9..12] 
      when :difficulty 
        collection = {:introductory => 1, :intermediate => 2, :advanced => 3}
      when :subjects 
        collection = Subject.all
      when :states 
        collection = ['DL','HR','PB','MH','WB','UP','TN']
      when :percentages 
        collection = 0.step(101,5).to_a 
    end 

    unless collection.nil? || collection.empty?
      select_box = semantic_fields_for prefix do |a| 
                     a.input singular, :as => :select, :collection => collection, 
                     :include_blank => include_blank,
                     :input_html => { :disabled => disabled,
                                      :slider => slider }
                   end 
    end # submitted by params as : criterion => {:state => "MH", :difficulty => "2"}

    class_attr = options[:float].nil? ? 'left dropdown' : 
                      (options[:float] == :right ? 'right dropdown' : 'left dropdown')

    if options[:id].nil? 
      content_tag(:div, select_box, :id => "#{singular}-dropdown", 
                  :class => class_attr)
    else 
      content_tag(:div, select_box, :id => "#{singular}-dropdown", 
                  :class => class_attr, :marker => "#{id}")
    end 
  end # of helper  

  def nofrills_checkbox(options = {}) 
    name = options[:name].nil? ? nil : options[:name]
    float = options[:float].nil? ? :left : options[:float]
    class_attr = (float == :none) ? 'checkbox' : ('checkbox ' + float.to_s)
    label = options[:label].nil? ? false : options[:label]
    
    unless label 
      c = content_tag(:div, tag(:input, :type => 'checkbox', :name => name), :class => class_attr)
    else
      random_id = rand(27**3).to_s(36).upcase
      c = content_tag :div, :class => class_attr do 
            tag(:input, :type => 'checkbox', :name => name, :id => random_id) + 
            content_tag(:label, label, :for => random_id, :class => 'small')
          end 
    end 
    return c 
  end 

end # of helper class
