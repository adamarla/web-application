
class DispatchMail < Struct.new(:mail)
  def perform
    mail.deliver
  end

  def max_attempts
    3
  end

  def reschedule_at
    10.minutes.from_now
  end

end
