require 'uri'
require 'net/http'


class CommonLegoKitFinder
  def search_url(part_number)
    "http://www.bricklink.com/catalogItemIn.asp?P=#{part_number}&in=S"
  end

  def get_all_kits_with_part(part_number)
    url = search_url(part_number)
    response = Net::HTTP.get_response(URI.parse(url).host, URI.parse(url).path)
    response.body
  end
end


@finder = CommonLegoKitFinder.new

p @finder.get_all_kits_with_part(3737)
