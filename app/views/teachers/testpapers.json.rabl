
collection @testpapers => :testpapers 
  attributes :id
  code :atm do |t|
    t.quiz.atm_key
  end
  node(:name) { |m| m.quiz.name }
  node(:ticker) { |m| "#{m.name} (#{m.created_at.to_date.strftime '%b %Y'})" }
