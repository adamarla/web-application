
# Standard format json for when the json would be used to 
# create a preview. See also quizzes/preview.json.rabl

object false => :preview
  node(:scans) { |m| @questions }
