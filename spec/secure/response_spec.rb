module Secure
  describe Response do
    it "knows if it is successful" do
      response = Response.success(2)
      response.should be_success
      response.value.should == 2
    end

    it "knows if it is an error" do
      response = Response.error(SecurityError.new)
      response.should_not be_success
      response.error.should be_a(SecurityError)
    end
  end
end
