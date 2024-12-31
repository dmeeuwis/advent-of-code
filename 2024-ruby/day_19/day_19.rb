require 'byebug'

parts = File.read(ARGV[0]).split("\n\n")
patterns = parts[0].split(", ")
designs = parts[1].split("\n")

@memo = {}

def count_design(design, patterns)
  return @memo[design] if @memo[design]

  if design.size == 0
    return 1
  end

  sum = 0
  patterns.each do |pattern|
    if design.start_with?(pattern)
      count = count_design(design[pattern.size..], patterns)
      sum += count
    end
  end

  @memo[design] = sum
  sum
end

possible = 0
sum = 0
designs.each do |design|
  count = count_design(design, patterns)
  puts "Design #{design}: #{count}"
  possible += 1 if count > 0
  sum += count
end

puts "Found #{possible} possible designs, with a total of #{sum} designs"