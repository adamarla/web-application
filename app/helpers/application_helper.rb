module ApplicationHelper

  def simple_link( options = {} )
    # Example: simple_link :for => "Download", :data => { :url => 'a/b', :ajax => true, :update_on => 'quizzes/list' }
    text = options.delete :for 
    href = options.delete(:href) || "#" 
    id = options.delete :id
    klass = options.delete :class 
    marker = options.delete :marker
    data = {}

    unless id.blank?
      onclick = OnClick[id]
      unless onclick.nil?
        first_level_keys = [
        'left', 'middle', 'right', 'wide', 
        'autoclick','ajax','attach', 'toggle', 'default-lnk', 
        'panel', 'prev', 'id'
        ]

        first_level_keys.each do |m|
          k = options.delete(m) || onclick[m] # HAML gets preference over YAML
          unless k.blank?
            if k.is_a? Hash
              ['show', 'ajax', 'tab'].each { |n| data["#{m}-#{n}"] = k[n] unless k[n].blank? } 
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

    return false if text.blank?
    attributes = tag_options data, true
    "<a #{attributes}>#{text}</a>".html_safe
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
    default = options[:default].nil? ? false : options[:default]
    label = options[:as] || name
    block_ajax = options[:block_ajax] || nil
    select_sth = options[:select_sth] || nil

    if type == :main
      singular = name.singularize
      plural = name.pluralize
      dynamic = options[:dynamic].nil? ? true : options[:dynamic] 
      class_attr = 'main-link'

      if dynamic
         # for main-links, the side-panel is fixed. Anything else specified 
         # using :with is ignored   

         panels = with.blank? ? {} : with[:panels] 
         panels = panels.merge( { :side => "##{plural}-summary" } )
         controls = (with.blank? || with[:controls].blank?) ? "##{singular}-controls" : with[:controls]
      else 
         panels = {} 
         controls = nil 
      end 
    elsif type == :minor 
      class_attr = 'minor-link'
      panels = with.blank? ? {} : with.delete(:panels) 
      controls = nil # minor-links cannot load any controls
    end 

    
    link = link_to label.humanize, href, :id => "#{name}-link", :class => class_attr, 
                               :side => panels[:side], :middle => panels[:middle], 
                               :right => panels[:right], :wide => panels[:wide], 
                               'load-controls' => controls, :default => default,
                               :block_ajax => block_ajax, :select_sth => select_sth

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
        collection = {'junior school(<9)' => 1, 'middle(9-10)' => 2, 'senior(11-12)' => 3}
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

    case options[:float]
      when :right then class_attr = 'right dropdown'
      when :none then class_attr = 'dropdown'
      else class_attr = 'left dropdown'
    end

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
