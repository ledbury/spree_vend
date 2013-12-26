class VendMailer < ActionMailer::Base
  attr_accessor :info_recipients, :error_recipients

  def initialize(method_name=nil, *args)
    @info_recipients = SpreeVend.info_recipients
    @error_recipients = SpreeVend.error_recipients
    super(method_name, *args)
  end

  def info_mail(message, subject=nil)
    subject ||= "Vend Notification"
    mail(
      :to => info_recipients,
      :subject => subject,
      :body => message)
  end
  
  def error_mail(message, subject=nil)
    subject ||= "Vend Error Notification"
    mail(
      :to => error_recipients,
      :subject => subject,
      :body => message)
  end
  
end
