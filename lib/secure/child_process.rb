module Secure
  class ChildProcess
    def initialize(opts, read_file, write_file)
      read_file.close
      @pipe = write_file
      @timeout = opts[:timeout] || 1
    end

    def guard_threads
      @guard_threads || []
    end

    def safely_run_block
      thread = Thread.start do
        $SAFE=3
        yield
      end

      guard_threads << GuardThread.kill_thread_on_timeout(@timeout, thread)

      Response.success(thread.value)
    rescue Exception => e
      Response.error(e)
    end

    def execute
      ret = safely_run_block { yield }
      @pipe.write(Marshal.dump(ret))
    end
  end
end
