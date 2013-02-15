module Secure
  class Runner
    def initialize(opts = {}, *args)
      @opts = opts
      @args = args
      @timeout = opts[:timeout]
    end

    def run
      read_file, write_file = IO.pipe

      child = fork do
        begin
          ChildProcess.new(@opts, read_file, write_file).execute { yield *@args }
        ensure
          exit
        end
      end
      Timeout.timeout @timeout do
        Process.wait(child)
      end
      ParentProcess.new(read_file, write_file).execute
    rescue Timeout::Error
      Process.kill(9, child)
      raise
    ensure
      read_file.close unless read_file.closed?
      write_file.close unless write_file.closed?
    end
  end
end
