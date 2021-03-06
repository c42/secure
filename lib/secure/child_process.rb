require 'base64'

module Secure
  class ChildProcess
    def initialize(opts, read_file, write_file)
      read_file.close
      @pipe = write_file
      @timeout = opts[:timeout]
      @limit_memory = opts[:limit_memory]
      @limit_cpu = opts[:limit_cpu]
      @limit_files = opts[:limit_files]
      @limit_procs = opts[:limit_procs]
      @pipe_stdout = opts[:pipe_stdout]
      @pipe_stderr = opts[:pipe_stderr]
      @pipe_stdin = opts[:pipe_stdin]
      @run_before = opts[:run_before]
      @safe_value = opts[:safe] || 3
    end

    def guard_threads
      @guard_threads || []
    end

    def set_resource_limits
      Process::setrlimit(Process::RLIMIT_AS, @limit_memory) if @limit_memory
      Process::setrlimit(Process::RLIMIT_CPU, @limit_cpu, 1 + @limit_cpu) if @limit_cpu
      Process::setrlimit(Process::RLIMIT_NOFILE, @limit_files, @limit_files) if @limit_files
      Process::setrlimit(Process::RLIMIT_NPROC, @limit_procs, @limit_procs) if @limit_procs
    end

    def redirect_files
      $stdout.reopen(@pipe_stdout) if @pipe_stdout
      $stderr.reopen(@pipe_stderr) if @pipe_stderr
      $stdin.reopen(@pipe_stdin) if @pipe_stdin
    end

    def run_before_methods
      return unless @run_before
      if @run_before.is_a? Array
        @run_before.each &:call
      else
        @run_before.call
      end
    end

    def secure_process
      run_before_methods
      set_resource_limits
      $SAFE = @safe_value
    end

    def safely_run_block
      redirect_files
      thread = Thread.start do
        sleep
        secure_process
        yield
      end
      decorate_with_guard_threads(thread)
      thread.wakeup
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
