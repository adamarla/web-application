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

end
