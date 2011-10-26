module Secure
  describe Runner do
    it "should execute normal code as expected" do
      response = Runner.new.run do
        4 + 4
      end
      response.should be_success
      response.value.should == 8
    end

    it "should kill all threads after running" do
      response = Runner.new.run do
        10
      end
      response.should be_success
      Thread.list.should have(1).things
    end

    it "should take parameters" do
      response = Runner.new({}, 4, 2).run do |a, b|
        a + b
      end
      response.should be_success
      response.value.should == 6
    end

    it "should accept a block that is run before safeing" do
      run_before = lambda { $FOO = $SAFE }
      response = Runner.new(:run_before => run_before ).run do
        $FOO
      end
      response.should be_success
      response.value.should == 0
    end

    it "accepts multiple blocks that are run before safeing" do
      before_1 = lambda { $FOO = 1 }
      before_2 = lambda { $BAR = 2 }
      response = Runner.new(:run_before => [before_1, before_2] ).run do
        $FOO + $BAR
      end
      response.should be_success
      response.value.should == 3
    end

    context "safe value" do
      it "should be set to 3" do
        response = Runner.new.run do
          $SAFE
        end
        response.should be_success
        response.value.should == 3
      end

      it "should not be affected in the parent thread" do
        response = Runner.new.run {}
        response.should be_success
        $SAFE.should == 0
      end

      it "can change the safe value if needed" do
        response = Runner.new(:safe => 0).run do
          $SAFE
        end
        response.should be_success
        response.value.should == 0
      end
    end

    context "security violations" do
      it "should not allow an eval to be called" do
        response = Runner.new.run do
          eval "45"
        end
        response.should_not be_success
        response.error.should be_a(SecurityError)
      end

      it "should not allow system calls" do
        response = Runner.new.run do
          system("echo hi")
        end
        response.should_not be_success
        response.error.should be_a(SecurityError)
      end

      it "should kill infinite loops" do
        response = Runner.new(:timeout => 0.005).run do
          while true; end
        end
        response.should_not be_success
        response.error.should be_a(Secure::TimeoutError)
      end

      if RUBY_PLATFORM =~ /darwin/
        pending "should kill a process with too much memory (does not work on OSX)"
        pending "kills a process trying to fork (does not work on OSX)"
      else
        it "should kill a process with too much memory on linux" do
          response = Runner.new(:limit_memory => 10 * 1024).run do
            'a' * 10 * 1024
          end
          response.should_not be_success
          response.error.should be_a(NoMemoryError)
        end

        it "kills a process trying to fork" do
          response = Runner.new(:safe => 0, :limit_procs => 0).run do
            fork do
              exit
            end
            10
          end
          response.should_not be_success
          response.error.should be_a(Errno::EMFILE)
        end
      end

      it "kills a process using too much cpu" do
        response = Runner.new(:limit_cpu => 1).run do
          while true; end
        end
        response.should_not be_success
        response.error.should be_a(Secure::ChildKilledError)
      end

      it "kills a process running trying to open a file" do
        response = Runner.new(:safe => 0, :limit_files => 0).run do
          File.read(__FILE__)
        end
        response.should_not be_success
        response.error.should be_a(Errno::EMFILE)
      end


      it "should not be able to open a file" do
        response = Runner.new.run do
          File.open("/etc/passwd")
        end
        response.should_not be_success
        response.error.should be_a(SecurityError)
      end
    end

    context "allowed syntax" do
      it "should allow eval on an untainted string" do
        string = "45".untaint
        response = Runner.new({}, string).run do |str|
          eval(str)
        end
        response.should be_success
        response.value.should == 45
      end

      it "should be able to read from an open file" do
        file = File.open("/etc/hosts")
        response = Runner.new({}, file).run do |file|
          file.readline
        end
        response.should be_success
      end
    end

    context "error information" do
      it "should know where the syntax is invalid" do
        string = "while true; end; end"
        response = Runner.new({}, string).run do |string|
          eval(string)
        end
        response.should_not be_success
        response.error.should be_a(SyntaxError)
      end
    end

    context "redirections" do
      let(:pipe) { IO.pipe }
      let(:read_file) { pipe[0] }
      let(:write_file) { pipe[1] }

      after(:each) do
        write_file.close unless write_file.closed?
        read_file.close unless read_file.closed?
      end

      it "redirects standard output" do
        response = Runner.new(:pipe_stdout => write_file).run do
          p "foobar"
        end
        write_file.close
        read_file.read.should == "\"foobar\"\n"
      end

      it "redirects standard output" do
        response = Runner.new(:pipe_stderr => write_file).run do
          $stderr.puts "\"foobar\""
        end
        write_file.close
        read_file.read.should == "\"foobar\"\n"
      end

      # This is pending because of some rspec wierdness that readline reads the first line of spec fil
      pending "redirects standard input" do
        write_file.puts "foobar"
        write_file.close
        response = Runner.new(:pipe_stdin => read_file).run do
          readline
        end
        response.value.should == "foobar\n"
      end
    end
  end
end
