
collection @verticals => :verticals
  attributes :name, :id 
  node(:tag) { |m| "#{Question.where(:topic_id => m.topic_ids).count} ques" }
