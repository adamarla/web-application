
# This file will be picked up automatically. Everything inside initializers/ is
# But more importantly, so will lib/gutenberg.rb because of config.autoload_paths
# setting in application.rb

Gutenberg.config = YAML.load_file("config/gutenberg.yml")
