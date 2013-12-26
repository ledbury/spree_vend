class SpreeVend::Notification
  attr_reader :subject, :message, :error

  def initialize(message, error=nil)
    @message = message
    @error = error
    @subject = error? ? "Vend Exception Notification" : "Vend Notification"
  end

  def log_info
    SpreeVend::Logger.info message
  end

  def log_error
    SpreeVend::Logger.error error_body
  end

  def error?
    !error.nil?
  end

  def error_body
    raise VendPosError, "You are trying to generate an error body without an error." unless error?
    [message, error.inspect, error.backtrace].flatten.join("\n")
  end

  def mail_notification
    if error?
      VendMailer.error_mail(error_body, subject).deliver
    else
      VendMailer.info_mail(message, subject).deliver
    end
  end

  class << self

    def info(message)
      notification = new message
      notification.log_info
      notification.mail_notification
    end

    def error(e, message)
      notification = new message, e
      notification.log_error
      notification.mail_notification
    end

  end

end
