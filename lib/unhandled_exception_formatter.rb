# frozen_string_literal: true

require_relative 'unhandled_exception_formatter/version'

# Custom formatter class for RSpec.
class UnhandledExceptionFormatter
  ::RSpec::Core::Formatters.register self, :example_failed

  DEFAULT_BACKTRACE_LENGTH = 10

  class << self
    # @return [Exception]
    attr_accessor :unhandled_exception

    # @return [Exception]
    attr_writer :backtrace_length

    # @return [Integer]
    def backtrace_length
      @backtrace_length ||= DEFAULT_BACKTRACE_LENGTH
    end
  end

  def initialize(output)
    @output = output
  end

  def example_failed(_notification)
    exception = self.class.unhandled_exception
    return if exception.nil?

    @output.puts(
      Message.new(
        backtrace_length: self.class.backtrace_length,
        exception: exception
      ).to_s
    )
  end

  # Internal class to represent a message.
  class Message
    # @param [Integer] backtrace_length
    # @param [Exception] exception
    def initialize(
      backtrace_length:,
      exception:
    )
      @backtrace_length = backtrace_length
      @exception = exception
    end

    # @return [String]
    def to_s
      <<~TEXT
        Unhandled exception:
          class:
            #{@exception.class}
          message:
            #{@exception}
          short backtrace:
        #{indented_short_backtrace_text}
      TEXT
    end

    private

    # @return [String]
    def indented_short_backtrace_text
      short_backtrace.join("\n").gsub(/^(?!$)/, ' ' * 4)
    end

    # @return [Array<String>]
    def short_backtrace
      (@exception.backtrace || []).take(@backtrace_length)
    end
  end
end
