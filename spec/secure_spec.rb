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
    #response.error.should be_a?(SecurityError)
  end

  it "should not allow system calls" do
    response = Secure.ly do
      system("echo hi")
    end
    response.should_not be_success
    #response.error.should be_a?(SecurityError)
  end

  it "should have safe value set" do
    response = Secure.ly do
      $SAFE
    end
    response.should be_success
    response.value.should == 3
  end

  #it "should not allow infinite loops" do
    #lambda do
      #Secure.ly do
        #while true; end
      #end
    #end
  #end
end
