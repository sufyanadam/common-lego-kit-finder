require 'nokogiri'
require 'open-uri'

class CommonLegoKitFinder
  attr_accessor :found_parts
  attr_accessor :unknown_parts
  attr_accessor :found_kits

  def initialize
    @unknown_parts = []
    @found_parts = {}
    @found_kits = {}
  end

  def search_url(part_number)
    "http://www.bricklink.com/catalogItemIn.asp?P=#{part_number}&in=S"
  end

  def get_file_contents(path)
    file_contents = File.read path
    file_contents
  end

  def extract_part_numbers_from(input)
    part_numbers = input.gsub!('.DAT','' ).split
    puts "found #{part_numbers.length} parts: #{part_numbers}"
    part_numbers
  end

  def get_kits_containing_part(part_number)
    p 'called!!!!!!!!!'
    @found_parts[part_number] = {:part_name => nil, :kits => []}

    page = Nokogiri::HTML(open(search_url(part_number)))

    if page.xpath('//font[@size="+2"]').text.include? "No Item(s) were found.  Please try again!"
      @unknown_parts << part_number
    end

    part_name = page.xpath('//table[@width="100%" and @border="0" and @cellpadding="10" and @cellspacing="0" and @bgcolor="#FFFFFF"]/tr/td/center/font/b').text
    table = page.xpath('//table[@border="0" and @cellpadding="3" and @cellspacing="0" and @width="100%"][preceding::p]')
    trs = table.xpath('./tr')

    trs.each_with_index do |row, index|
      puts "processing rows for part #{part_number}, #{part_name}"

      if index > 2
        puts "getting row #{index}"

        tds = row.xpath('./td')

        if tds.count < 6
          puts "could not process row #{index} because td layout is not acceptable"
          puts tds
          puts "sorry..."
          next
        end

        qty_in_kit = /\d/.match(tds[1].text)[0]
        kit_number = /\d+-*\d*/.match(tds[2].text)[0]
        kit_name = tds[3].xpath('./font/b').text
        kit_description = tds[3].xpath('./font[2]/br/preceding-sibling::text()').text
        kit_year = tds[4].xpath('./font').text

        @found_parts[part_number][:part_name] = part_name
        @found_parts[part_number][:kits] << { :kit_number => kit_number, :kit_name => kit_name, :kit_description => kit_description, :year => kit_year, :qty_in_kit => qty_in_kit }

        @found_kits[kit_number] = {:kit_name => kit_name, :kit_description => kit_description, :year => kit_year}
        @found_kits[kit_number][:found_parts] ||= []
        @found_kits[kit_number][:found_parts] << {:part_number => part_number, :part_name => part_name, :qty_in_kit => qty_in_kit}
        @found_kits[kit_number][:missing_parts] ||= []
        @found_kits[kit_number][:missing_parts] << {:part_number => part_number, :part_name => part_name}
      end
    end

    @found_parts
  end

  def get_required_kits
    puts "sorted!"
    puts @found_kits.sort_by { |kit_number, kit_info| kit_info[:found_parts].length }.reverse!
    # get the top 5 kits that contained most of the parts
    # these kits contain all the parts you seek
    found_parts = @found_kits.map { |kit, kit_info| kit_info[:found_parts]}
    puts "the parts!!!!!!!"
    puts found_parts
  end
end
