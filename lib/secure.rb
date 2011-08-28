require "secure/version"
require "secure/response"
require "secure/runner"

module Secure
  class << self
    def run
      Runner.run do
        yield
      end
    end

    alias :ly :run
  end
end
