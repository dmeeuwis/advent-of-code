require 'byebug'

input = File.read(ARGV[0])
range_lines = input.split(',')
ranges = range_lines.map do |line|
  line.split('-').map { |x| x.to_i }
end

def count_range(range)
  start, finish = range
  matches = []
  (start..finish).each do |i|
    m = mirror?(i)
    if m
      matches.push(m)
      puts "\tMirror! #{m}"
    end
  end

  matches
end

def split_in_half(str)
  mid = str.length / 2
  [str[0...mid], str[mid..-1]]
end

def mirror?(val)
  str = val.to_s
  first, second = split_in_half(str)
  if first == second
    val
  else
    nil
  end
end

all_matches = []
ranges.each do |range|
  c = count_range(range)
  puts "#{range} has count #{c.size} #{c}"
  all_matches += c
end  

puts "Final matches: #{all_matches}"
puts "Final sum: #{all_matches.sum}"
