
object false
  node(:questions) {
    @questions.map{ |m|
      n = @context == 'addhints' ? m.hints.count : nil
      {
        name: m.simple_uid,
        id: m.id,
        klass: m.set_filter_classes(current_account),
        tag: ( n.nil? ? nil : "#{n} hint(s)" )
        # video: (m.video.nil? ? nil : m.video.uid)
      }
    }
  }

  node(:topic) { @topic }
  node(:last_pg) { @last_pg }
  node(:pg) { @pg }
  node(:context) { @context }
