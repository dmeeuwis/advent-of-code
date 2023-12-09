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

pos = starting_nodes
puts "Starting at #{starting_nodes}"
steps = 0
loop_steps = starting_nodes.map { -1 }

seen = Set.new

while !pos.all? { |p| p.nil? }
  dir = rl.next

  pos.each_with_index do |p, index|
    next if p == nil
    step_index = steps % rl_line.size
    key = [index, dir, p, step_index]
    if seen === key
      puts "Found a loop #{key} at step #{steps}"
      n = desert[p][directions[dir]]
      puts "Next would have been #{n}"
      pos[index] = nil
      loop_steps[index] = steps
      break
    else
      seen.add key
      n = desert[p][directions[dir]]
      puts "#{key} => #{n} (#{steps})"
      pos[index] = n
    end
  end
  steps += 1
end

puts "Found loops at: #{loop_steps}"
lcm = loop_steps.reduce(1) { |acc, n| acc.lcm(n) }
puts "LCM = #{lcm}"