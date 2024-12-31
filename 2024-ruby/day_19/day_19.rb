require 'byebug'

parts = File.read(ARGV[0]).split("\n\n")
patterns = parts[0].split(", ")
designs = parts[1].split("\n")

def count_design(design, patterns, trails = [])
  if design.size == 0
    #puts "Found design: #{trails}"
    return 1
  end

  sum = 0
  patterns.each do |pattern|
    if design.start_with?(pattern)
      trail_dup = trails.dup
      trail_dup.push(pattern)
      sum += count_design(design[pattern.size..], patterns, trail_dup)
    end
  end

  sum
end

possible = 0
designs.each do |design|
  count = count_design(design, patterns)
  puts "Design #{design}: #{count}"
  possible += 1 if count > 0
end

puts "Found #{possible} possible designs"