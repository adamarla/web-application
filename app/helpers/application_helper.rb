module ApplicationHelper

  def simple_link( options = {} )
    # Example: simple_link :for => "Download", :data => { :url => 'a/b', :ajax => true, :update_on => 'quizzes/list' }
    text = options.delete :for 
    dropdown = options.delete :as
    dropdown = dropdown.blank? ? false : true
    icon = dropdown ? options.delete(:icon) : nil

    return false if (text.blank? && icon.blank?) # one or the other has to be there

    href = options.delete(:href) || "#" 
    id = options.delete :id
    klass = options.delete :class 
    klass = dropdown ? (klass.blank? ? "dropdown-toggle" : klass + " dropdown-toggle") : klass
    marker = options.delete :marker
    data = {}

    unless id.blank?
      onclick = OnClick[id]
      unless onclick.nil?
        first_level_keys = [
          :left,
          :middle, 
          :right, 
          :wide, 
          :ajax,
          :autoclick,
          :attach,
          :toggle, 
          'default-lnk', 
          :panel, 
          :prev, 
          :id, 
          :menu, 
          'update-on', 
          :url,
          :notouch
        ]

        first_level_keys.each do |m|
          k = options.delete(m) || onclick[m.to_s] # HAML gets preference over YAML
          # puts " --> #{k} --> #{id}" if m == :ajax
          unless k.blank?
            # puts " ******** [#{id}]: #{m} --> #{k}" 
            if k.is_a? Hash
              ['show', 'url', 'tab', 'link'].each { |n| data["#{m}-#{n}"] = k[n] unless k[n].blank? } 
            else
              data[m] = k
            end
          end # of unless 
        end # of do .. 
      end # of unless 
    end # of unless 

    # If not from YAML, then attributes coming exclusively from HAML. Don't ignore those 
    options.each do |k,v|
      data[k] = v
    end

    data = {:id => id, :class => klass, :href => href, :data => data, :marker => marker}

    attributes = tag_options data, true
    if dropdown
      if icon.blank?
        html = "<a #{attributes}>#{text}<span class='caret'></span></a>" 
      else
        html = "<a #{attributes}><i class='#{icon}'></i>#{text}<span class='caret'></span></a>" 
      end
    else
      html = "<a #{attributes}>#{text}</a>" 
    end
    return html.html_safe
    # "<a #{attributes}>#{text}</a>".html_safe
  end 

  # Generates a <button> with either an icon, text or both and an optional radio/checkbox
  # Example: simple_button :for => "submit", :icon => 'icon-star', :class => 'btn-warning', :as => :radio, :name => "checked[25]"
  def simple_button( options = {} )
    label = options.delete :for
    icon = options.delete :icon

    return false unless ( label || icon )
    as = options.delete :as 
    name = options.delete :name 

    return false if (as.blank? ^ name.blank?) # either both present or neither
    klass = options.delete(:class) || "btn-inverse"
    id = options.delete :id
    tooltip = options.delete(:tooltip) || nil

    content_tag :button, :class => "btn #{klass}", :id => id, 
      :rel => "#{tooltip.nil? ? nil : :tooltip}", :title => "#{tooltip.nil? ? nil : tooltip}" do
      render = label.blank? ? "" : label 
      render += (icon.blank? ? "" : content_tag(:i, nil, :class => "icon-white #{icon}") )
      unless as.blank?
        render += (as == :radio) ? 
                  radio_button_tag(name, true, false, :class => :hide) : 
                  check_box_tag(name, true, false, :class => :hide)
      end
      render.html_safe
    end
  end

  def html_attrs(lang = 'en-US')
    {:xmlns => "http://www.w3.org/1999/xhtml", 'xml:lang' => lang, :lang => lang}
  end 

  def text_search_box_for(name) 
    x = semantic_fields_for :criterion do |a| 
          a.input "#{name.to_s}", :as => :string, 
          :wrapper_html => {:class => 'search-box'},
          :input_html => {:size => 10}
        end 
    content_tag(:div, x) 
  end 

=begin
   Usage Example : drop_down_menu_for :subjects, :disabled => true, :name => 'subjects[1]'
   Options : 
         :disabled => [true | false] 
         :name => < string > (default = :criterion) 
         :include_blank => [true | false]
         :slider => [true | false] (Sets attribute 'slider=true' attribute on the dropdown) 
=end 

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

########################################################
  def get_list_of( what )
    case what 
      when :boards then return Board.where('id IS NOT NULL')
      when :topics then return Topic.where('id IS NOT NULL').order(:name)
      when :verticals then return Vertical.where('id IS NOT NULL').order(:name)
      else return []
    end 
  end 

end # of helper class
