
module Gutenberg 
  
  def config 
    @@config ||= {}
  end

  def config=(hash)
    @@config = hash
  end

  # Allows us to make calls like ApplicationSettings.config 
  module_function :config, :config=

end
