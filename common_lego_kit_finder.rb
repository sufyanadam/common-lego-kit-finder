require 'nokogiri'
require 'open-uri'

class CommonLegoKitFinder
  attr_accessor :lego_parts

  def search_url(part_number)
    "http://www.bricklink.com/catalogItemIn.asp?P=#{part_number}&in=S"
  end

  def extract_part_numbers
    file_contents = File.read "/Users/Sufyan/Dropbox/lego_part_numbers"

    part_numbers = file_contents.scan /\w*\d+/
    part_numbers.to_a
  end

  def get_kit_list_for_part(part_number)
    puts "processing rows for part #{part_number}"
    found_kits = {}
    found_kits[part_number] = []

    page = Nokogiri::HTML(open(search_url(part_number)))

    table = page.xpath('//table[1][@border="0" and @cellpadding="3" and @cellspacing="0" and @width="100%"][preceding::p]')

    trs = table.xpath('./tr')
    trs.each_with_index do |row, index|
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

        #kit = LegoKit.new(part_number, kit_number, kit_name, kit_description, kit_year)

        #found_kits[part_number] = kit
        found_kits[part_number] << { :searched_part => part_number, :number => kit_number, :name => kit_name, :description => kit_description, :year => kit_year }
      end
    end

    found_kits
  end
end

class LegoPart
  attr_accessor :part_number
  attr_accessor :contained_in_kits
  attr_accessor :part_image

  def initialize(part_number, contained_in_kits)
    @part_number = part_number
    @contained_in_kits = contained_in_kits
  end
end

class LegoKit
  attr_accessor :searched_part
  attr_accessor :kit_number
  attr_accessor :kit_name
  attr_accessor :kit_description
  attr_accessor :kit_year
  attr_accessor :kit_image

  def initialize(searched_part, kit_number, kit_name, kit_description, kit_year)
    @searched_part = searched_part
    @kit_number = kit_number
    @kit_name = kit_name
    @kit_year = kit_year
  end
end
