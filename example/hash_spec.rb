describe Hash do
	before do
		@hash = Hash.new({:hello => 'world'})
	end

	it "should return a blank instance" do
		Hash.new.should == {}
	end

	it "hash the correct information in a key" do
		@hash[:hello].should == 'world'
	end
end
