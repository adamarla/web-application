# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
 ActiveSupport::Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
   inflect.irregular 'syllabus', 'syllabi'
   inflect.irregular 'pending', 'pending'
   inflect.irregular 'coursework', 'coursework'
   inflect.irregular 'freebie', 'freebies'
   inflect.irregular 'criterion', 'criteria'
   inflect.irregular 'watan', 'watan'
   inflect.irregular 'kaagaz', 'kaagaz'
   inflect.irregular 'codex', 'codices'
   inflect.irregular 'koshish', 'koshishein'
   inflect.irregular 'potd', 'potd'
 end
