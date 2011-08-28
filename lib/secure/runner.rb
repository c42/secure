module Secure
  class Runner
    def initialize(opts)
      @timeout = opts[:timeout] || 1
    end

    def guard_threads
      @guard_threads || []
    end

    def run
      thread = Thread.start do
        $SAFE=3
        Response.success(yield)
      end

      guard_threads << GuardThread.kill_thread_on_timeout(@timeout, thread)

      thread.value
    rescue SecurityError, TimeoutError => e
      Response.error(e)
    ensure
      #guard_threads.each(&:exit!)
    end
  end
end
