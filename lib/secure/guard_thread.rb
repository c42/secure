module Secure
  class GuardThread < Thread
    class << self
      def kill_thread_on_timeout(secs, thread)
        Thread.start(secs, thread) do |s, t|
          t.join(s)
          t.raise(TimeoutError, "This thread has taken more than #{s} seconds")
        end
      end
    end
  end
end
