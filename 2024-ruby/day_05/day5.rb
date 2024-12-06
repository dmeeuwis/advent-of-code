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

sum = 0
updates.each do |update|
  res = check_update(update, before_rules)
  if res
    # get the middle element
    raise "Invalid update" if update.size.even?
    middle = update[update.size/2]
    sum += middle
  end
  puts "#{update} is valid? #{res}"
end

puts
puts "Sum is #{sum}"