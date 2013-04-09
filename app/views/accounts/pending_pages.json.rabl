

object false 
  node(:pages) {
    @pages.map { |m| 
      { :name => "Page ##{m}", :id => m, :badge => @gr.on_page(m).map(&:scan).uniq.count }
    } 
  } 
