module Secure
  class Response
    attr_reader :error, :value

    def initialize(error, value)
      @error = error
      @value = value
    end

    def success?
      error.nil?
    end

    class << self
      def success(value)
        Response.new(nil, value)
      end

      def error(error)
        Response.new(error, nil)
      end
    end
  end
end
