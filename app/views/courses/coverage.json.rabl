
collection @macros => :macros
  attributes :name, :id
  code :in do |m|
    @course.covers_macro_topic? m.id
  end 

  child :micro_topics => :micros do 
    attributes :name, :id
    code :difficulty do |k|
      k.difficulty_in @course.id
    end 
  end 
