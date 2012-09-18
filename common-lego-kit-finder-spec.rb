require './common_lego_kit_finder'
require 'open-uri'

describe CommonLegoKitFinder do
  before do
    @finder = CommonLegoKitFinder.new
    html = File.read "output.html"
    CommonLegoKitFinder.stub(:open, anything) { html }
  end

  describe "#search_url" do
    it "returns the correct bricklink url for a given part" do
      @finder.search_url(3737).should == "http://www.bricklink.com/catalogItemIn.asp?P=3737&in=S"
    end
  end

  describe "#extract_part_numbers_from" do
    it "extracts a list of part numbers into an array from a string" do
      input = "32316.DAT 43857.DAT 32016.DAT 41677.DAT 41677.DAT 41677.DAT 32270.DAT 6575.DAT x253.DAT 3749.DAT"
      @finder.extract_part_numbers_from(input).should == %w[32316 43857 32016 41677 41677 41677 32270 6575 x253 3749]
    end
  end

  describe "#get_kits_containing_part" do
    it "returns a hash containing all the kits in which the given part appears" do
      @finder.get_kits_containing_part(53787).should == {53787=>{:part_name=>"Electric, Motor - NXT", :kits=>[{:kit_number=>"8527-1", :kit_name=>"LEGO Mindstorms NXT", :kit_description=>"578 Parts, 1 Gear", :year=>"2006", :qty_in_kit=>"3"}, {:kit_number=>"9797-1", :kit_name=>"Mindstorms Education NXT Base Set", :kit_description=>"432 Parts, 4 Gear", :year=>"2006", :qty_in_kit=>"3"}, {:kit_number=>"8547-1", :kit_name=>"Mindstorms NXT 2.0", :kit_description=>"620 Parts, 1 Gear", :year=>"2009", :qty_in_kit=>"3"}, {:kit_number=>"9842-1", :kit_name=>"NXT Servo Motor", :kit_description=>"1 Part", :year=>"2006", :qty_in_kit=>"1"}]}}
    end
  end

  describe "#get_required_kits" do
    before do
      @finder.get_kits_containing_part 53787
    end
    it "returns a list of all the kits required to obtain all the parts in the input list" do
      @finder.get_required_kits
      false.should be_true
    end
  end
end
