require "secure/version"
require "secure/response"

module Secure
  class << self
    def run
      $SAFE = 3
      begin
        Response.success(yield)
      rescue SecurityError => e
        Response.error(e)
      end
    end

    alias :ly :run
  end
end
