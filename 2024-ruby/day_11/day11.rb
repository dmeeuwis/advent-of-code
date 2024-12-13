require 'byebug'

@memo = {}

def rule(stone)
  return @memo[stone] if @memo[stone]
  res = rule_internal(stone)
  @memo[stone] = res
  res
end

def rule_internal(stone)
  if stone == 0
    return [1]
  elsif stone.to_s.chars.size % 2 == 0
    return [stone.to_s[0..stone.to_s.size/2 - 1].to_i, stone.to_s[stone.to_s.size/2..-1].to_i]
  else
    return [stone * 2024]
  end
end

def blink(line)
  line.map { |stone| rule(stone) }.flatten
end

line = File.readlines(ARGV[0]).first.split.map(&:to_i)
puts "Line: #{line.join(' ')}"

#(1..25).to_a.each do |i|
# i.times do
#   line = blink(line)
# end
# puts "#{i}: #{line.size}"
#end


75.times do |i|
  puts "Blink! #{i}"
  line = blink(line)
end
puts line.size
