require 'set'
require 'byebug'

directions = { "L" => 0, "R" => 1 }

f = File.open(ARGV[0])
lines = f.readlines.map { |l| l.chomp }

rl_line = lines.shift
rl = (rl_line * 99999).chars
lines.shift

map = {}
lines.each do |l| 
  l =~ /(\w+) = \((\w+), (\w+)\)/
  node, node_l, node_r = $1, $2, $3
  map[node] = [node_l, node_r]
end
puts map

pos = "AAA"
puts "Starting at AAA"
steps = 0

while pos != "ZZZ"
  dir = rl.shift
  puts "#{dir} => #{directions[dir]}, at pos #{pos} #{map[pos]}" 
  pos = map[pos][directions[dir]]
  steps += 1
  puts "=> #{pos}, #{steps} steps"
end

puts "Got there in #{steps} steps."
