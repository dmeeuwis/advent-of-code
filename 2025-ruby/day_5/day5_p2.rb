lines = File.read(ARGV[0]).split("\n")

parts = lines.chunk { |x| x.empty? }.reject { |is_empty, _| is_empty }.map(&:last)
id_ranges, available_ids = parts

ranges = id_ranges.map do |r|
  r.split('-').map(&:to_i)
end.sort_by { |start, _| start }

merged = []
ranges.each do |start, finish|
  if merged.empty? || merged.last[1] < start - 1
    merged << [start, finish]
  else
    merged.last[1] = [merged.last[1], finish].max
  end
end

total = merged.sum { |start, finish| finish - start + 1 }
puts total
