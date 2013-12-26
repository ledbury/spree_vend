class SpreeVend::Logger < ::Logger

  def initialize
    super("#{Rails.root}/log/vend.log")
    @level = ::Logger::INFO
    @formatter = ::Logger::Formatter.new
    @datetime_format = "%Y-%m-%d %H:%M:%S"
  end

  def self.info(message)
    new.info(message)
  end

  def self.error(message)
    new.error(message)
  end

end
