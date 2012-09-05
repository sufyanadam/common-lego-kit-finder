require './common_lego_kit_finder'


describe CommonLegoKitFinder do
  before do
    @finder = CommonLegoKitFinder.new
  end

  it "generates the correct search url given the part number" do
    @finder.search_url(3737).should == "http://www.bricklink.com/catalogItemIn.asp?P=3737&in=S"
  end

  it "extracts all kits containing the part number from the page" do

  end
end
