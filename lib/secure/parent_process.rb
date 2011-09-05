require 'base64'

module Secure
  class ParentProcess
    def initialize(read_file, write_file)
      @pipe = read_file
      write_file.close
    end

    def execute
      Marshal.load(Base64.decode64(@pipe.read))
    rescue
      Response.error(ChildKilledError.new("Child has been killed without returning"))
    end
  end
end
