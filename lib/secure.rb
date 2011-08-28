require "secure/version"
require "secure/response"

module Secure
  class << self
    def run
      $SAFE = 3
      begin
        yield
      rescue SecurityError => e
        e
      end
    end

    alias :ly :run
  end
end
