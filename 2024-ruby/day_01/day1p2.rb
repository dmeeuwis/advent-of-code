
lines = File.readlines ARGV[0]
rows = lines.map { |line| line.strip.split(/\s+/) }
col1 = rows.map { |row| row[0].to_i }
col2 = rows.map { |row| row[1].to_i }

col1s = col1.sort
col2s = col2.sort

counts = Hash.new { |h, k| h[k] = 0 }
col2s.each_with_index do |val, i|
  counts[val] += 1
end

sim_score = 0
col1s.each_with_index do |val, i|
  sim_score += counts[val] * val
end

puts "Sim score: #{sim_score}"