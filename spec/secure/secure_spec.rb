describe Secure do
  it "should execute normal code as expected" do
    Secure.ly do
      4 + 4
    end.should == 8
  end

  #it "should not allow an eval to be called" do
    #Secure.ly do
      #eval "45"
    #end.should == SecurityError
  #end

  #it "should not allow system calls" do
    #Secure.ly do
      #system("echo hi")
    #end.should == SecurityError
  #end

  #it "should not allow infinite loops" do
    #lambda do
      #Secure.ly do
        #while true; end
      #end
    #end
  #end
end
