require 'set'
require 'byebug'

directions = { "L" => 0, "R" => 1 }

f = File.open(ARGV[0])
lines = f.readlines.map { |l| l.chomp }

rl_line = lines.shift
rl = rl_line.chars.cycle
lines.shift

desert = {}
lines.each do |l| 
  l =~ /(\w+) = \((\w+), (\w+)\)/
  node, node_l, node_r = $1, $2, $3
  desert[node] = [node_l, node_r]
end

starting_nodes = []
desert.keys.each do |key|
  if key[-1] == 'A'
    starting_nodes.push key
  end
end
puts "Found #{starting_nodes.size} ending nodes: #{starting_nodes}"

ending_nodes = []
desert.keys.each do |key|
  if key[-1] == 'A'
  ending_nodes.push key
  end
end
puts "Found #{ending_nodes.size} ending nodes: #{ending_nodes}."

pos = starting_nodes.clone
puts "Starting at #{starting_nodes}"
steps = 0
loop_steps = starting_nodes.map { -1 }

while !pos.all? { |p| p.nil? }
  dir = rl.next



  pos.each_with_index do |p, index|
    next if p.nil?
    pos[index] = desert[p][directions[dir]]
    #puts "=> #{pos}, #{steps} steps"

    if p[-1] == 'Z'
      pos[index] = nil
      puts "Found Z Ending #{p} for #{starting_nodes[index]} #{index} at steps #{steps}"
      loop_steps[index] = steps
    end
  end
  steps += 1
end

puts loop_steps

#  pos.each_with_index do |p, index|
#   next if p == nil
#   n = desert[p][directions[dir]]
#   steps += 1
#   #puts "#{p} => #{n} (#{steps})"
#   pos[index] = n

#   if n[-1] == 'Z'
#     pos[index] = nil
#     puts "Found Z ending for #{index} at #{steps}"
#     loop_steps[index] = steps
#   end
# end
#end

puts "Found loops at: #{loop_steps}"
lcm = loop_steps.reduce(1) { |acc, n| acc.lcm(n) }
puts "LCM = #{lcm}"
