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

  def drop_down_menu_for (name) 
    collection = nil 
    name = (name == :difficulty) ? name : name.to_s.pluralize.to_sym

    case name
      when :boards 
        collection = Board.all 
      when :classes 
        collection = [*9..12] 
      when :difficulty 
        collection = {:introductory => 1, :intermediate => 2, :advanced => 3}
      when :subjects 
        collection = Subject.all
    end 

    unless collection.nil? || collection.empty?
      select_box = semantic_fields_for :criterion do |a| 
                     a.input name, :as => :select, :include_blank => false, 
                                   :collection => collection
                   end 
    end 
    return content_tag(:div, select_box, :id => "#{name.to_s.singularize}-dropdown", :class => 'right dropdown')
  end 

end # of helper class
