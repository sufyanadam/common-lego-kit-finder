require './common_lego_kit_finder'
require 'awesome_print'

@finder = CommonLegoKitFinder.new

#@parts = [53787, 55804]

#@parts = ["x344"]

#@parts = @finder.extract_part_numbers

def get_kits_containing(part_numbers)
  kits = []

  part_numbers.each do |pn|
    kits << @finder.get_kits_containing_part(pn)
  end

  kits
end


def identify_kit_occurrences_in(kits)
  seen_kits = {}

  kits.each do |k|
    k.map do |key, kit_info_hash_array|
      kit_info_hash_array.each do |info_hash|
        if seen_kits[info_hash[:kit_number]]
          seen_kits[info_hash[:kit_number]][:appearance_count] += 1
          seen_kits[info_hash[:kit_number]][:contains_searched_parts] << key
          seen_kits[info_hash[:kit_number]][:quantities] << { :part_number => key, :part_name => info_hash[:part_name], :qty => info_hash[:qty_in_kit] }
        else
          seen_kits[info_hash[:kit_number]] = { :appearance_count => 1, :contains_searched_parts => [key], :kit_name => info_hash[:kit_name], :quantities => [{ :part_number => key, :part_name => info_hash[:part_name], :qty => info_hash[:qty_in_kit] }], :description => info_hash[:kit_description], :year => info_hash[:year] }
        end
      end
    end
  end

  @parts = @parts - @finder.unknown_parts
  seen_kits
end

def rank_kits_and_display(kit_occurrences)
  ranked_by_occurrence = kit_occurrences.sort_by do |kit_number, stats|
    stats[:appearance_count]
  end.reverse

  searched_parts = @parts

  all_kits_with_all_parts = []

  ranked_by_occurrence.each do |kit_info_array|
    found_parts = kit_info_array[1][:contains_searched_parts].uniq
    next if (searched_parts & found_parts).length < 1

    missing_parts = searched_parts - found_parts
    kit_info_array[1][:missing_parts] = missing_parts if missing_parts.length > 0

    all_kits_with_all_parts << kit_info_array

    searched_parts = searched_parts - found_parts
  end while searched_parts.length > 0

  puts "The following kits will have all the parts you need:"
  puts all_kits_with_all_parts
  puts "The following part numbers were not found:"
  puts @finder.unknown_parts
end

kits = get_kits_containing @parts
occurrences = identify_kit_occurrences_in kits
rank_kits_and_display occurrences
