require './common_lego_kit_finder'

@finder = CommonLegoKitFinder.new

parts = [53787, 55804]

parts = @finder.extract_part_numbers

kit_lists = []

parts.each do |p|
  kit_lists << @finder.get_kit_list_for_part(p)
end

seen_kits = {}

kit_lists.each do |l|

  l.map do |key, hash_array|
    hash_array.each do |hash|
      if seen_kits[hash[:number]]
        seen_kits[hash[:number]][:appearance_count] += 1
      else
        seen_kits[hash[:number]] = { :appearance_count => 1, :searched_part => key }
      end
    end
  end
end

puts seen_kits
