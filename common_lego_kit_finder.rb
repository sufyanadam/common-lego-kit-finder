# require 'uri'
# require 'net/http'
require 'nokogiri'
require 'open-uri'

class CommonLegoKitFinder
  def search_url(part_number)
    "http://www.bricklink.com/catalogItemIn.asp?P=#{part_number}&in=S"
  end

  def get_kit_list_for_part(part_number)
    page = Nokogiri::HTML(open(search_url(part_number)))

    table = page.xpath('//table[1][@border="0" and @cellpadding="3" and @cellspacing="0" and @width="100%"][preceding::p]')

    trs = table.xpath('./tr')
    trs.each_with_index do |row, index|
      if index > 2
        puts "row number: #{index}"
        tds = row.xpath('./td')
        puts tds
      end
    end
  end
end
