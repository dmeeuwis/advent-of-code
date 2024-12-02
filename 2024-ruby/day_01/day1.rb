require 'byebug'
# read in example.txt
lines = File.readlines ARGV[0]
rows = lines.map { |line| line.strip.split(/\s+/) }
col1 = rows.map { |row| row[0].to_i }
col2 = rows.map { |row| row[1].to_i }

col1s = col1.sort
col2s = col2.sort

diff = 0
col1s.each_with_index do |val, i|
  diff += (col1s[i] - col2s[i]).abs
end

puts "Total distance is #{diff}"