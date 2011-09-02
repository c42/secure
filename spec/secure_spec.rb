describe Secure do
  it "should execute a block with params" do
    Secure.ly({}, 4, 2) do |a, b|
      a + b
    end.should eq(6)
  end

  it "should throw an exception if block fails" do
    lambda { Secure.ly(:timeout => 0.1) { while true; end } }.should raise_error(Secure::TimeoutError)
  end
end
