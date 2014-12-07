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
      get_kits_containing(part_number)
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
      puts "processing rows for part #{part_number}, #{part_name}"

      if row_number > 2
        results[part_number][:kits] << process_row(row, row_number)
      end

      #   results[kit_number] = {:kit_name => kit_name, :kit_description => kit_description, :year => kit_year}
      #   results[kit_number][:found_parts] ||= []
      #   results[kit_number][:found_parts] << {:part_number => part_number, :part_name => part_name, :qty_in_kit => qty_in_kit}
      #   results[:found_kits][kit_number][:missing_parts] ||= []
      #   results[:found_kits][kit_number][:missing_parts] << {:part_number => part_number, :part_name => part_name}
    end

    results
  end

  def process_row(row, row_number)
    puts "getting row #{row_number}"

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
            :qty_in_kit => qty_in_kit
           }
  end


  def get_kits_containing_part(part_number)
    results = {
      :found_parts => {part_number => {:part_name => nil, :kits => []}},
      :found_kits  => {},
      :unknown_parts => []
    }

    page = Nokogiri::HTML(open(search_url(part_number)))

    if page.xpath('//font[@size="+2"]').text.include? "No Item(s) were found.  Please try again!"
      results[:unknown_parts] << part_number
    end

    part_name = page.xpath('//table[@width="100%" and @border="0" and @cellpadding="10" and @cellspacing="0" and @bgcolor="#FFFFFF"]/tr/td/center/font/b').text
    table = page.xpath('//table[@border="0" and @cellpadding="3" and @cellspacing="0" and @width="100%"][preceding::p]')
    trs = table.xpath('./tr')

    trs.each_with_row_number do |row, row_number|
      puts "processing rows for part #{part_number}, #{part_name}"

      if row_number > 2
        puts "getting row #{row_number}"

        tds = row.xpath('./td')

        if tds.count < 6
          puts "could not process row #{row_number} because td layout is not acceptable"
          puts tds
          puts "sorry..."
          next
        end

        qty_in_kit = /\d/.match(tds[1].text)[0]
        kit_number = /\d+-*\d*/.match(tds[2].text)[0]
        kit_name = tds[3].xpath('./font/b').text
        kit_description = tds[3].xpath('./font[2]/br/preceding-sibling::text()').text
        kit_year = tds[4].xpath('./font').text

        results[:found_parts][part_number][:part_name] = part_name
        results[:found_parts][part_number][:kits] << { :kit_number => kit_number, :kit_name => kit_name, :kit_description => kit_description, :year => kit_year, :qty_in_kit => qty_in_kit }

        results[:found_kits][kit_number] = {:kit_name => kit_name, :kit_description => kit_description, :year => kit_year}
        results[:found_kits][kit_number][:found_parts] ||= []
        results[:found_kits][kit_number][:found_parts] << {:part_number => part_number, :part_name => part_name, :qty_in_kit => qty_in_kit}
        results[:found_kits][kit_number][:missing_parts] ||= []
        results[:found_kits][kit_number][:missing_parts] << {:part_number => part_number, :part_name => part_name}
      end
    end

    results
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
