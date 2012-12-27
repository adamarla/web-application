# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Webapp::Application.initialize!


# Using YAML to set application-wide variables - Railscast #85
Gutenberg = YAML.load_file("#{Dir.pwd}/config/gutenberg.yml")[Rails.env]
OnClick = YAML.load_file("#{Dir.pwd}/config/onclick.yml")

Rubric = YAML.load_file("#{Dir.pwd}/config/rubric.yml")['rubric']['maths']
# Set the start-indices of the first item under various heads
['cogent', 'complete', 'other'].each do |m| 
  case m
    when 'cogent'
      prev = ['honest']
    when 'complete'
      prev = ['honest', 'cogent']
    when 'other'
      prev = ['honest', 'cogent', 'complete']
  end
  n = 0 
  prev.each { |m| n += Rubric[m].length } 
  Rubric['start'][m] = n
end 

SavonClient = Savon::Client.new do
  wsdl.document = "#{Gutenberg['wsdl']}"
  wsdl.endpoint = "#{Gutenberg['axis2']}"
end

SavonClient.http.read_timeout = 600 # 10 mins seems good enough to finish most SOAP operations
