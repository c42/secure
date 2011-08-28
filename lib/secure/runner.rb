module Secure
  class Runner
    def self.run
      Thread.start do
        $SAFE=3
        Response.success(yield)
      end.value
    rescue SecurityError => e
      Response.error(e)
    end
  end
end
