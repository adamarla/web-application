# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Webapp::Application.initialize!


# Using YAML to set application-wide variables - Railscast #85
Gutenberg = YAML.load_file("#{Dir.pwd}/config/gutenberg.yml")[Rails.env]
OnClick = YAML.load_file("#{Dir.pwd}/config/onclick.yml")
Rubric = YAML.load_file("#{Dir.pwd}/config/rubric.yml")['rubric']

SavonClient = Savon::Client.new do
  wsdl.document = "#{Gutenberg['wsdl']}"
  wsdl.endpoint = "#{Gutenberg['axis2']}"
end

SavonClient.http.read_timeout = 600 # 10 mins seems good enough to finish most SOAP operations
