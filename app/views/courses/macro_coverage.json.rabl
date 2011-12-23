
collection @macros => :macros
  attributes :name, :id
  code :in do |m|
    @course.covers_macro_topic? m.id
  end 
