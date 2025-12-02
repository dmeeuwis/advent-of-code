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

def split_into(str, n)
  return [str] if n == 1
  return [] if n > str.length || n < 1

  base_size = str.length / n
  remainder = str.length % n

  parts = []
  offset = 0

  n.times do |i|
    size = base_size + (i < remainder ? 1 : 0)
    parts << str[offset, size]
    offset += size
  end
  
  parts
end

def mirror?(val)
  str = val.to_s

  for i in 2..val.size
    parts = split_into(val.to_s, i)
    #puts "\tparts for #{val} #{i}: #{parts}"
    if parts.uniq.size == 1
      return parts.join.to_i
    end
  end

  false
end

all_matches = []
ranges.each do |range|
  c = count_range(range)
  puts "#{range} has count #{c.size} #{c}"
  all_matches += c
end  

puts "Final matches: #{all_matches}"
puts "Final sum: #{all_matches.sum}"
