module ApplicationHelper

  def get_onclick_data(id)
    ret = OnClick[id]
    return ret unless ret.blank?
    # Allow keys that are actually reg-exps. Useful when a whole family of similarly named 
    # keys need to be generated via a for loop in the HAML
    keys = OnClick.keys
    matches = keys.map{ |k| /#{k}/.match("#{id}") } # k could be a reg-exp
    idx = matches.index{ |m| m }
    ret = idx.nil? ? nil : OnClick[keys[idx]] # first place where reg-ex match passes
    return ret
  end 

  def simple_link( options = {} ) 
    text = options.delete :for 
    icon = options.delete :icon
    return false if (text.blank? && icon.blank?) # one or the other has to be there

    data = {}
    attributes = {}

    # HAML: non data-* attributes
    [:href, :id, :class, :marker, :target].each do |k|
      v = options.delete(k)
      attributes[k] = ( k == :href ) ? (v || '#') : v
    end

    # YAML: data-* always
    id = attributes[:id]
    onclick = id.blank? ? nil : get_onclick_data(id)
    # debug = id.blank? ? false : (id == 'lnk-about-us')

    is_dropdown = false
    is_tab = id.blank? ? false : !id.match(/^tab-/).nil?
    is_modal = false
    is_no_touch = true
    is_help = id.blank? ? false : !id.match(/^help-/).nil? # all <a> within m-howto have IDs starting w/ help-*

    #puts "[tab]: #{id}" if is_tab

    unless onclick.nil?
      onclick.keys.each do |k| # k = show | autoclick | prev | id | url ....
        spec = onclick[k]
        spec.is_a?(Hash) ? spec.keys.each { |j| data["#{k}-#{j}"] = spec[j] } : (data[k] = spec)
        if k == 'show'
          ['left', 'middle', 'right', 'wide', 'superwide'].each do |v|
            is_no_touch &= spec[v].blank?
            break unless is_no_touch 
          end 
          is_dropdown = !spec['menu'].nil?
          is_modal = !spec['modal'].nil?
        end # of if ... 

        if (is_dropdown || is_modal || is_tab)
          data[:toggle] = is_tab ? :tab : (is_modal ? :modal : :dropdown) 
        end

      end # of do ... 
    else # no entry in YAML => no-touch
      data[:toggle] = :tab if is_tab
    end # of unless 

    klass = attributes[:class]
    klass = is_dropdown ? (klass.blank? ? "dropdown-toggle" : "#{klass} dropdown-toggle") : klass
    klass = is_help ? (klass.blank? ? "help" : "#{klass} help") : klass
    attributes[:class] = klass

    # Set inferred value for no-touch
    data['no-touch'] = true if is_no_touch

    # HAML: Remaining attributes - always data-*
    options.each do |k,v| 
      if v.is_a? Hash
        v.keys.each { |j| data["#{k}-#{j}"] = v[j] }
      else
        data[k] = v
      end
    end
    
    # Generate the HTML 
    attributes[:data] = data
    tags = tag_options attributes, true

    if is_dropdown
      html = icon.blank? ? "<a #{tags}> #{text} <span class='caret'></span></a>" :
                           "<a #{tags}> <i class='#{icon} icon-white'></i> #{text} <span class='caret'></span></a>"
    else
      html = icon.blank? ? "<a #{tags}> #{text} </a>" :
                           "<a #{tags}> <i class='#{icon} icon-white'></i> #{text} </a>"
    end
    return html.html_safe
  end 

  # Generates a <button> with either an icon, text or both and an optional radio/checkbox
  # Example: 
  #     simple_button 
  #          for: :submit, 
  #          icon: 'icon-star', 
  #          class: 'btn-warning', 
  #          as: :radio, 
  #          name: 'checked[25]', 
  #          shortcut: 'A',
  #          tooltip: 'this button does X'

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
    type = options.delete(:type) || :button
    kb = options[:kb] || nil
    options[:kb] = options[:kb].downcase unless options[:kb].blank?

    unless tooltip.nil?
      rel = :tooltip
      title = tooltip
    else
      rel = title = placement = nil
    end

    content_tag :button, class: "btn #{klass}", type: type, id: id, rel: rel, title: title, data: options do 
      render = label.blank? ? "" : (kb.blank? ? label : "<span class='kb'>#{kb}</span>#{label}")
      render += (icon.blank? ? "" : content_tag(:i, nil, :class => "icon-white #{icon}") )
      unless as.blank?
        render += (as == :radio) ? 
                  radio_button_tag(name, true, false, :class => :hide) : 
                  check_box_tag(name, true, false, :class => :hide)
      end
      render.html_safe
    end
  end

  def partial_path(pth)
    x = pth.sub /.*views\//, '' # remove everything upto app/views/
    y = x.split('.')[0] # remove .html.haml
    z = y.sub /_/, ''
    return z
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

end # of helper class
