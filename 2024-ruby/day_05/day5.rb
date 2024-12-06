require 'byebug'

lines = File.readlines ARGV[0]
split_index = lines.index("\n")

before_rules = {}
after_rules = {}
rules = lines[0..split_index-1].map(&:strip).map do |rule|
   parts = rule.split("|")
   before_rules[parts[1].to_i] = parts[0].to_i
   after_rules[parts[0].to_i] = parts[1].to_i
end

update_lines = lines[split_index+1..-1].map(&:strip)
updates = update_lines.map do |update|
  update.split(",").map(&:to_i)
end


def check_update(update, before_rules, after_rules)
  update.each_with_index do |page, index|
    before = update[0...index]
    after = update[index+1...]

    before.each do |b|
      if after_rules[page] == b
        return false
      end
    end

    after.each do |a|
      if before_rules[page] == a
        return false
      end
    end
  end

  true
end

sum = 0
updates.each do |update|
  res = check_update(update, before_rules, after_rules)
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