require 'byebug'

@memo = {}

def blink(stone, blinks)
  return @memo[[stone, blinks]] if @memo[[stone, blinks]]

  res = stone
  blinks.times do
    res = res.map { |stone| rule_internal(stone) }.flatten
  end

  @memo[[stone, blinks]] = res
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

line = File.readlines(ARGV[0]).first.split.map(&:to_i)
puts "Line: #{line.join(' ')}"

blinks = (ARGV[1] || "1").to_i
out_line = []
sum = 0
line.each do |rock|
  res = blink([rock], blinks)
  out_line += res
  sum += res.size
end
puts out_line.inspect
puts sum
