require './common_lego_kit_finder'
require 'awesome_print'

@finder = CommonLegoKitFinder.new

# @parts = [53787, 55804]
# @parts = [32526, 32528, 6632, 32269]
# @parts = [32526, 32528, 32269]
#@parts = [53787]

# @parts = [55804]
#@parts = ["x344"]
file_contents = @finder.get_file_contents "/Users/Sufyan/Dropbox/lego_part_numbers"
@parts = @finder.extract_part_numbers_from file_contents

def get_kits_containing(part_numbers)
  @finder.get_kits_containing_parts part_numbers
end


def identify_kit_occurrences_in(parts_to_kits_hash)
  seen_kits = {}

  parts_to_kits_hash.each do |kh|
    kh.map do |part_number, kit_info_hash_array|
      kit_info_hash_array[:kits].each do |info_hash|
        if seen_kits[info_hash[:kit_number]]
          seen_kits[info_hash[:kit_number]][:appearance_count] += 1
          seen_kits[info_hash[:kit_number]][:contains_searched_parts] << part_number
          seen_kits[info_hash[:kit_number]][:quantities] << { :part_number => part_number, :part_name => kit_info_hash_array[:part_name], :qty => info_hash[:qty_in_kit] }
        else
          seen_kits[info_hash[:kit_number]] = { :appearance_count => 1, :contains_searched_parts => [part_number], :kit_name => info_hash[:kit_name], :quantities => [{ :part_number => part_number, :part_name => kit_info_hash_array[:part_name], :qty => info_hash[:qty_in_kit] }], :description => info_hash[:kit_description], :year => info_hash[:year] }
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

def find_minimum_kits(part_numbers)
  parts_in_kits = get_kits_containing @parts
  found_parts = parts_in_kits.map { |pik| pik.keys }.flatten
  most_frequently_occurring_kit = @finder.get_most_occurring_kit(parts_in_kits)
  parts_in_most_frequently_occurring_kit = parts_in_kits.select { |hash| hash[hash.keys.first] && hash[hash.keys.first][:kits] && hash[hash.keys.first][:kits].map { |kit_hash| kit_hash && kit_hash[:kit_number] == most_frequently_occurring_kit  } }.map { |found| found.keys }.flatten
  parts_not_found_in_most_frequently_occurring_kit = found_parts - parts_in_most_frequently_occurring_kit
  p 'the parts not found in this round:', parts_not_found_in_most_frequently_occurring_kit
  p 'the kit(s) you must find to get all the parts you need is', most_frequently_occurring_kit
end
find_minimum_kits @parts
exit
