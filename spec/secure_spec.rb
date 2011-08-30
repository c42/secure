describe Secure do
  it "should execute normal code as expected" do
    response = Secure.ly do
      4 + 4
    end
    response.should be_success
    response.value.should == 8
  end

  it "should kill all threads after running" do
    response = Secure.ly do
      10
    end
    response.should be_success
    Thread.list.should have(1).things
  end

  it "should take parameters" do
    response = Secure.ly({}, 4, 2) do |a, b|
      a + b
    end
    response.should be_success
    response.value.should == 6
  end

  context "safe value" do
    it "should be set to 3" do
      response = Secure.ly do
        $SAFE
      end
      response.should be_success
      response.value.should == 3
    end

    it "should not be affected in the parent thread" do
      response = Secure.ly {}
      response.should be_success
      $SAFE.should == 0
    end
  end

  context "security violations" do
    it "should not allow an eval to be called" do
      response = Secure.ly do
        eval "45"
      end
      response.should_not be_success
      response.error.should be_a(SecurityError)
    end

    it "should not allow system calls" do
      response = Secure.ly do
        system("echo hi")
      end
      response.should_not be_success
      response.error.should be_a(SecurityError)
    end

    it "should kill infinite loops" do
      response = Secure.ly :timeout => 0.005 do
        while true; end
      end
      response.should_not be_success
      response.error.should be_a(Secure::TimeoutError)
    end

    it "should not be able to open a file" do
      response = Secure.ly do
        File.open("/etc/passwd")
      end
      response.should_not be_success
      response.error.should be_a(SecurityError)
    end
  end

  context "allowed syntax" do
    it "should allow eval on an untainted string" do
      string = "45".untaint
      response = Secure.ly({}, string) do |str|
        eval(str)
      end
      response.should be_success
      response.value.should == 45
    end

    it "should be able to read from an open file" do
      file = File.open("/etc/hosts")
      response = Secure.ly({}, file) do |file|
        file.readline
      end
      response.should be_success
    end
  end

  context "error information" do
    it "should know where the syntax is invalid" do
      string = "while true; end; end"
      response = Secure.ly({}, string) do |string|
        eval(string)
      end
      response.should_not be_success
      response.error.should be_a(SyntaxError)
    end
  end
end
