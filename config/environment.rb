# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Webapp::Application.initialize!


# Using YAML to set application-wide variables - Railscast #85
Gutenberg = YAML.load_file("#{Dir.pwd}/config/gutenberg.yml")[Rails.env]
OnClick = YAML.load_file("#{Dir.pwd}/config/onclick.yml")

SavonClient = Savon::Client.new do
  wsdl.document = "#{Gutenberg['wsdl']}"
  wsdl.endpoint = "#{Gutenberg['axis2']}"
end

SavonClient.http.read_timeout = 600 # 10 mins seems good enough to finish most SOAP operations

# Indices of quizzes, sections, whatever that we pre-fabricate for new users
PREFAB_SECTION = 58
PREFAB_DEMO_QUIZ = 318
PREFAB_QUIZ_ALGEBRA = 337
PREFAB_QUIZ_CALCULUS = 338
PREFAB_QUIZ_TRIGO = 339
PREFAB_QUIZ_GEOMETRY = 340
PREFAB_QUIZ_PROBABILITY = 341

PREFAB_QUIZ_IDS = [*PREFAB_QUIZ_ALGEBRA..PREFAB_QUIZ_PROBABILITY]
PREFAB_QUIZ_MAP = { :algebra => 337, :calculus => 338, :trigonometry => 339, :probability => 341 }

# Status codes for Delayed::Jobs 
JOB_INITIAL_STATE = -1 
WRITE_TEX_ERROR = -2 
COMPILE_TEX_ERROR = -3
