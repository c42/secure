require 'base64'

module Secure
  class ChildProcess
    def initialize(opts, read_file, write_file)
      read_file.close
      @pipe = write_file
      @timeout = opts[:timeout]
      @limit_memory = opts[:limit_memory]
      @limit_cpu = opts[:limit_cpu]
    end

    def guard_threads
      @guard_threads || []
    end

    def safely_run_block
      Process::setrlimit(Process::RLIMIT_AS, @limit_memory) if @limit_memory
      Process::setrlimit(Process::RLIMIT_CPU, @limit_cpu, 2 + @limit_cpu) if @limit_cpu
      thread = Thread.start do
        $SAFE=3
        yield
      end
      decorate_with_guard_threads(thread)
      Response.success(thread.value)
    rescue Exception => e
      Response.error(e)
    end

    def decorate_with_guard_threads(thread)
      GuardThread.kill_thread_on_timeout(@timeout, thread) if @timeout
    end

    def execute
      ret = safely_run_block { yield }
      @pipe.write(Base64.encode64(Marshal.dump(ret)))
    end
  end
end
