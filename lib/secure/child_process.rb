require 'base64'

module Secure
  class ChildProcess
    def initialize(opts, read_file, write_file)
      read_file.close
      @pipe = write_file
      @timeout = opts[:timeout]
      @limit_memory = opts[:limit_memory]
      @limit_cpu = opts[:limit_cpu]
      @pipe_stdout = opts[:pipe_stdout]
      @pipe_stderr = opts[:pipe_stderr]
      @pipe_stdin = opts[:pipe_stdin]
    end

    def guard_threads
      @guard_threads || []
    end

    def safely_run_block
      Process::setrlimit(Process::RLIMIT_AS, @limit_memory) if @limit_memory
      Process::setrlimit(Process::RLIMIT_CPU, @limit_cpu, 2 + @limit_cpu) if @limit_cpu
      $stdout.reopen(@pipe_stdout) if @pipe_stdout
      $stderr.reopen(@pipe_stderr) if @pipe_stderr
      $stdin.reopen(@pipe_stdin) if @pipe_stdin
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
