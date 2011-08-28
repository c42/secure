describe Secure do
  it "should execute normal code as expected" do
    response = Secure.ly do
      4 + 4
    end
    response.should be_success
    response.value.should == 8
  end

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

  it "should have safe value set" do
    response = Secure.ly do
      $SAFE
    end
    response.should be_success
    response.value.should == 3
  end

  it "should not have affected the global safe value" do
    response = Secure.ly {}
    response.should be_success
    $SAFE.should == 0
  end

  it "should kill infinite loops" do
    response = Secure.ly :timeout => 0.005 do
      while true; end
    end
    response.should_not be_success
    response.error.should be_a(Secure::TimeoutError)
  end

  it "should kill all threads after running" do
    Secure.ly do
      10
    end
    Thread.list.should have(1).things
  end
end
