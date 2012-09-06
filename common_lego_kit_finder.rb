# require 'uri'
# require 'net/http'
require 'nokogiri'
require 'open-uri'

class CommonLegoKitFinder
  def search_url(part_number)
    "http://www.bricklink.com/catalogItemIn.asp?P=#{part_number}&in=S"
  end

  def get_html_page
    page = Nokogiri::HTML(open(search_url(53787)))

    table = page.xpath('//table[1][@border="0" and @cellpadding="3" and @cellspacing="0" and @width="100%"][preceding::p]')

    puts table

    trs = table.xpath('./tr')

    puts 'trs!!!!!!!!!!!!!!!!!!!!!!!!!!'
    puts trs
    #tds = table.at_xpath('./tbody')

    # puts "the tds!"
    # puts tds
  end
end
