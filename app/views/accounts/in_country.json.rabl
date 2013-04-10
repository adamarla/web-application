
object false
  node(:accounts) {
    @accounts.map{ |m|
      last_logged_in = m.last_sign_in_at.nil? ? "Never" : "#{(Date.today - m.last_sign_in_at.to_date).to_i} days"
      badge = @type == 'Teacher' ? m.loggable.quiz_ids.count : nil
      { :id => m.id, :name => m.loggable.name, :tag => last_logged_in, :badge => badge }
    }
  }
