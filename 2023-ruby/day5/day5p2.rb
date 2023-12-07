require 'set'
require 'byebug'

f = File.open(ARGV[0])
lines = f.readlines.map { |l| l.chomp }

seeds_line = lines[0] =~ /seeds: (.*)/
seeds_nums = $1.split(" ").map { |s| s.to_i }
seeds = []
while !seeds_nums.empty? 
  start = seeds_nums.shift
  num = seeds_nums.shift
  seeds += (start..start+num-1).to_a
end

def parse_map(hash, input, from_sym, to_sym)
  input =~ /(\d+) (\d+) (\d+)/
  destination, source, range = $1.to_i, $2.to_i, $3.to_i

  hash.add_range(source, destination, range)
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

rangemaps = {} 

class RangeMap
  def initialize(source, destination)
    @ranges = []
    @source = source
    @destination = destination
  end

  def add_range(from, to, range)
    @ranges.push({ from: from, to: to, range: range })
  end

  def [](key)
    @ranges.each do |range|
      if key >= range[:from] && key <= range[:from] + range[:range]
        return range[:to] + (key - range[:from])
      end
    end
    key
  end
end

maps.each { |pair| rangemaps[pair] = RangeMap.new *pair }

mapmap = {}
maps.each do |pair|
  mapmap[pair[0]] = pair[1]
end

maps.each do |pair|
    #puts pair.inspect
    while !lines.empty? && !lines[0].empty? do
      #puts lines[0]
      parse_map(rangemaps[pair], lines.shift, pair[0], pair[1])
    end

    lines.shift
    lines.shift
end

min_seed = 999999999999999
seeds.each_with_index do |seed, index|
  if index % 1_000_000 == 0
    puts "Seed #{seed} (#{index+1}/#{seeds.size}) #{index / seeds.size.to_f * 100}%}"
  end
  chain = seed
  maps.each do |pair|
    chain = rangemaps[pair][chain]
    #puts "\t#{pair} -> #{chain}"
  end
  #puts "End of seed #{seed} is #{chain}"
  #puts
  min_seed = chain if chain < min_seed
end

puts min_seed
puts