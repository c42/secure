module Secure
  class ParentProcess
    def initialize(read_file, write_file)
      @pipe = read_file
      write_file.close
    end

    def execute
      Marshal.load(@pipe.read)
    end
  end
end
