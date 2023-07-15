f = open(ARGV[0])
lines = f.readlines

orbits = {}

lines.each do |l|
  parts = l.chomp.split ')'
  orbits[parts[1]] = parts[0]
end

puts orbits
counts = {}
orbits.keys.each do |p|
  count = 0
  pr = p
  while orbits[pr]
    count += 1
    pr = orbits[pr]
  end

  counts[p] = count
  puts "#{count} counted for #{p}"
end

total = counts.values.sum
puts "Part 1: #{total} orbits."

# find parents from SAN to root
def find_parents(node, graph, chain = [])
  if !graph[node]
    chain
  else
    chain.push node
    find_parents(graph[node], graph, chain)
  end
end

san_parents = find_parents('SAN', orbits)
you_parents = find_parents('YOU', orbits)
puts "San_parents: #{san_parents}"
puts "You_parents: #{you_parents}"

for p in you_parents
  check = san_parents.index p
  if check
    puts "Found merge point #{p}"
    check_you = you_parents.index p
    san_cut = san_parents[1..check-1]
    you_cut = you_parents[1..check_you]
    puts "san_cut: #{san_cut}"
    puts "you_cut: #{you_cut}"
    merge = san_cut + you_cut[1..]

    puts "Part 2: Merged: #{merge} #{merge.size}"
    exit(0)
  end
end

# Part 2: apply djistra's algorithm to find shorted distance from YOU to SAN
#visited = {}
#distance = {}
#orbits.keys.each do |p|
#  visited[p] = nil
#  distance[p] = Float::INFINITY
#end
#unvisited = Set.new(orbits.keys)
