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

  def get_kits_containing_parts(part_numbers)
    part_numbers.map do |part_number|
      get_kits_containing part_number
    end
  end

  def get_kits_containing(part_number)
    page = Nokogiri::HTML(open(search_url(part_number)))

    if page.xpath('//font[@size="+2"]').text.include? "No Item(s) were found.  Please try again!"
      return part_number => nil
    end

    part_name = page.xpath('//table[@width="100%" and @border="0" and @cellpadding="10" and @cellspacing="0" and @bgcolor="#FFFFFF"]/tr/td/center/font/b').text
    table = page.xpath('//table[@border="0" and @cellpadding="3" and @cellspacing="0" and @width="100%"][preceding::p]')
    trs = table.xpath('./tr')

    results = {
      part_number => {
        part_name: part_name,
        kits: []
      }
    }

    trs.each_with_index do |row, row_number|
      puts "processing row #{row_number} for part #{part_number}, #{part_name}"

      if row_number > 2
        results[part_number][:kits] << process_row(row, row_number)
      end
    end

    results[part_number][:top_kit] = results[part_number][:kits].find { |k| k[:qty_in_kit].to_i > (results[part_number][:top_kit] && results[part_number][:top_kit][:qty_in_kit]).to_i }

    results
  end

  def process_row(row, row_number)
    tds = row.xpath('./td')

    if tds.count < 6
      puts "could not process row #{row_number} because td layout is not acceptable"
      puts tds
      puts "sorry..."
      return
    end

    qty_in_kit = /\d/.match(tds[1].text)[0]
    kit_number = /\d+-*\d*/.match(tds[2].text)[0]
    kit_name = tds[3].xpath('./font/b').text
    kit_description = tds[3].xpath('./font[2]/br/preceding-sibling::text()').text
    kit_year = tds[4].xpath('./font').text

    return {
      :kit_number => kit_number,
      :kit_name => kit_name,
      :kit_description => kit_description,
      :year => kit_year,
      :qty_in_kit => qty_in_kit,
    }
  end

  def get_most_occurring_kit(parts_in_kits)
    seen_kits = {}

    parts_in_kits.each do |part_info_hash|
      part_info_hash.each do |part_number, info_hash|
        info_hash && info_hash[:kits] && info_hash[:kits].each do |kit_info_hash|
          next if kit_info_hash.nil?
          seen_kits[kit_info_hash[:kit_number]] = seen_kits[kit_info_hash[:kit_number]] ? seen_kits[kit_info_hash[:kit_number]] + 1 : 1
        end
      end
    end

    seen_kits.max { |a, b| a[1]  <=>  b[1] }
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
