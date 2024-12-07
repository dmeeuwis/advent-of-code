require 'byebug'

lines = File.readlines ARGV[0]
split_index = lines.index("\n")

before_rules = Hash.new { |h, k| h[k] = [] }
rules = lines[0..split_index-1].map(&:strip).map do |rule|
   parts = rule.split("|")
   before_rules[parts[0].to_i].push parts[1].to_i
end

update_lines = lines[split_index+1..-1].map(&:strip)
updates = update_lines.map do |update|
  update.split(",").map(&:to_i)
end


def check_update(update, before_rules)
  update.each_with_index do |page, index|
    after = update[index+1...]

    after.each do |a|
      if !before_rules[page].include? a
        return false
      end
    end
  end

  true
end

def check_permutations(update, before_rules)
  puts "Looking for permutations for #{update}"
  all_possible = update.permutation.to_a
  puts "Found #{all_possible.size} permutations"
  all_possible.each do |permutation|
    res = check_update(permutation, before_rules)
    if res
      middle = permutation[permutation.size/2]
      return middle
    end
  end
  nil
end

sum = 0
updates.each do |update|
  res = check_update(update, before_rules)
  if !res
    puts "Found bad update: #{update}"
    res = check_permutations(update, before_rules)
    if !res
      puts "Found invalid update: #{update}"
    else 
      puts "Found permutation for #{update} with middle #{res}"
      sum += res
    end
  end
end

puts
puts "Sum is #{sum}"