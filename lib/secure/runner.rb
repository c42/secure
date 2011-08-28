module Secure
  class Runner
    def self.run
      $SAFE=3
      Response.success(yield)
    rescue SecurityError => e
      Response.error(e)
    end
  end
end
