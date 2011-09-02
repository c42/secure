require "secure/version"
require "secure/response"
require "secure/errors"
require "secure/guard_thread"
require "secure/parent_process"
require "secure/child_process"
require "secure/runner"

module Secure
  class << self
    def run(opts = {}, *args)
      response = Runner.new(opts, *args).run do |*a|
        yield *a
      end

      raise response.error unless response.success?
      response.value
    end

    alias :ly :run
  end
end
