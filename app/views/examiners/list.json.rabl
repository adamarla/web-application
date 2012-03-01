
collection @examiners => :examiners
  attributes :name
  code :id do |m|
    m.is_admin ? 'highlight' : 'normal'
  end
