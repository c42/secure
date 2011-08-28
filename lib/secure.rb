require "secure/version"
require "secure/response"
require "secure/errors"
require "secure/guard_thread"
require "secure/runner"

module Secure
  class << self
    def run(opts = {})
      Runner.new(opts).run do
        yield
      end
    end

    alias :ly :run
  end
end
