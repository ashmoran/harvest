require 'forwardable'
require 'term/ansicolor'
require 'ap'

RSpec::Matchers.define :have_status_code do |expected_code|
  match do |response|
    response.code == expected_code
  end

  # TODO: only want to log the error on unexpected 500s etc
  failure_message_for_should do |response|
    "Expected response #{response} to have status #{expected_code}\n" +
    "Got: #{response.code}\n" +
    (response.error || "")
  end
end

RSpec::Matchers.define :have_content_type do |expected_content_type|
  match do |response|
    @actual_content_type = response.headers['Content-Type']
    @actual_content_type == expected_content_type
  end

  failure_message_for_should do |response|
    %'Expected response #{response} to have content type "#{expected_content_type}" but ' +
      if @actual_content_type
        %'got "#{@actual_content_type}"'
      else
        "the Content-Type header was not set"
      end
  end
end

module Webmachine
  # A decorator for resources to help in testing
  class TestResponse
    include Term::ANSIColor
    extend Forwardable

    def_delegators :@response,
      :headers, :code, :code=, :body, :body=, :redirect, :trace, :error, :error=,
      :do_redirect, :set_cookie,
      :is_redirect?, :redirect_to

    class << self
      def build
        new(Webmachine::Response.new)
      end
    end

    def initialize(response)
      @response = response
      @inspector = AwesomePrint::Inspector.new(
        multiline: false, color: { symbol: :purpleish }
      )
    end

    def trace_lines
      trace.map { |trace_hash|
        format_trace_line(trace_hash)
      }
    end

    # Handling all cases the same here because I'm no longer sure
    # if we want to do error formatting in this method
    def format_trace_line(line)
      case line[:type]
      when :response
        case line[:code].to_i
        when 500
          format_standard_line(line)
        else
          format_standard_line(line)
        end
      else
        format_standard_line(line)
      end
    end

    def format_standard_line(line)
      line.inject([ ]) { |line_parts, (key, value)|
        line_parts.concat([ "#{cyan(key.to_s)}: #{@inspector.awesome(value)}" ])
      }.join(", ")
    end
  end
end