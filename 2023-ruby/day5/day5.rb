require 'set'
require 'byebug'

f = File.open(ARGV[0])
lines = f.readlines.map { |l| l.chomp }

seeds_line = lines[0] =~ /seeds: (.*)/
seeds = $1.split(" ").map { |s| s.to_i }

def parse_map(hash, input, from_sym, to_sym)
  input =~ /(\d+) (\d+) (\d+)/
  destination, source, range = $1.to_i, $2.to_i, $3.to_i

  0..range.times do |i|
    hash[source +i] = destination+i 
  end
  hash
end

lines.shift
lines.shift
lines.shift

maps = [ [:seed, :soil],
         [:soil, :fertilizer],
         [:fertilizer, :water],
         [:water, :light],
         [:light, :temperature],
         [:temperature,:humidity],
         [:humidity, :location]
]

hashmaps = {} 
maps.each { |pair| hashmaps[pair] = Hash.new { |h, k| h[k] = k } }

mapmap = {}
maps.each do |pair|
  mapmap[pair[0]] = pair[1]
end

maps.each do |pair|
    puts pair.inspect
    while !lines.empty? && !lines[0].empty? do
      puts lines[0]
      parse_map(hashmaps[pair], lines.shift, pair[0], pair[1])
    end

    lines.shift
    lines.shift
end

min_seed = 99999
seeds.each do |seed|
  puts "Seed #{seed}"
  maps.each do |pair|
    chain = hashmaps[pair][seed]
    #puts "\t#{chain}"
  end
  puts "End of seed #{seed} is #{chain}"
  puts
  min_seed = chain[:address] if chain[:address]
end

puts min_seed