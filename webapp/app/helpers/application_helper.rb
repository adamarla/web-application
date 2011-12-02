module ApplicationHelper

  def html_attrs(lang = 'en-US')
    {:xmlns => "http://www.w3.org/1999/xhtml", 'xml:lang' => lang, :lang => lang}
  end 

  def side_panel_link (name, args = {})
    # 'dynamic' links are those that load tables and controls on click. Non-dynamic links, 
    # like for logout and login, don't

    link = nil 
    class_attr = args[:class].nil? ? 'main-link' : args[:class]
    href = args[:href].nil? ? '#' : args[:href]
    dynamic = args[:dynamic].nil? ? true : args[:dynamic]
    singular = name.to_s.singularize
    plural = name.to_s.pluralize

    if dynamic 
      table = "##{plural}-summary"
      panel = "##{singular}-controls" 

      link = link_to name.to_s, href, :id => "#{name}-link", :class => class_attr, 
                                      'load-table' => table, 'load-controls' => panel
    else 
      link = link_to name.to_s, href, :id => "#{name}-link", :class => class_attr 
    end 

    return content_tag(:li, link, :id => "#{singular}-anchor") 
  end 

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
        collection = [*0..100]
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
    class_attr = (float == :none) ? 'checkbox' : ('checkbox' + float.to_s)

    content_tag(:div, tag(:input, :type => 'checkbox', :name => name), :class => class_attr)
  end 

end # of helper class
