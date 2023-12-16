require 'byebug'
require 'set'

f = File.open(ARGV[0])
lines = f.readlines.map do |l| 
  parts = l.split(" ") 
  nums = parts[1].split(',').map &:to_i
  [parts[0], nums]
end

def fits(r, start, ender)
  return false if start - 1 < 0 || ender + 1 >= r.size
  return false if r[start-1] == '#' || r[ender+1] == '#'
  return false if r[..(start-1)]['#']
  (start..ender).each do |i|
    return false if r[i] == '.'
  end

  return true
end

$memoize = {}

def count_ways(record, groups)
  mkey = record + "_" + groups.join("_")
  if $memoize[mkey]
    return $memoize[mkey]
  end

  if groups.empty?
    if record['#']
      # if # marks are left in string, but no group, not valid
      #puts "\treturn 0"
      return 0 
    else 
      #puts "\treturn 1"
      return 1
    end
  end

  size = groups[0]
  groups = groups[1..]

  count = 0
  record.size.times do |ender|
    start = ender - (size - 1)

    if fits(record, start, ender)
      #puts "fits! #{record} #{start} #{ender}"
      count += count_ways(record[ender+1..], groups)
    else
      #puts "\tnot fits! #{record}, #{start}, #{ender}"
    end
  end

  $memoize[mkey] = count
  return count
end

sum_p1 = 0
lines.each do |input|
  record, groups = input
  record = "." + record + "."

  count = count_ways record, groups
  puts "Found #{count} ways."
  sum_p1 += count
end

puts
puts "Total: #{sum_p1}"

sum_p2 = 0
counts = lines.map do |input|
  record = "." + ([input[0]] * 5).join('?') + "."
  groups = input[1] * 5

  puts "Sprung: #{input} #{groups}"

  count = count_ways record, groups
  puts "Found #{count} ways."
  count
end
sum_p2 = counts.sum
puts "Part two: #{sum_p2}"
