module Secure
  class Runner
    def initialize(opts)
      @opts = opts
    end

    def run
      read_file, write_file = IO.pipe

      child = fork do
        begin
          ChildProcess.new(@opts, read_file, write_file).execute { yield }
        ensure
          exit
        end
      end

      Process.wait(child)
      ParentProcess.new(read_file, write_file).execute
    ensure
      read_file.close unless read_file.closed?
      write_file.close unless write_file.closed?
    end
  end
end
