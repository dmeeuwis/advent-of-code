lines = File.read(ARGV[0]).split("\n")

parts = lines.chunk { |x| x.empty? }.reject { |is_empty, _| is_empty }.map(&:last)
id_ranges, available_ids = parts

puts "ID ranges"
puts id_ranges
ranges = id_ranges.map do |r|
  parts = r.split('-').map(&:to_i)
  Range.new(parts[0], parts[1])
end

puts ranges

puts "Available ids"
puts available_ids

fresh = Set.new
available_ids.each do |id|
  ranges.each do |r|
    if r.include? id.to_i
      puts "#{id} is fresh!"
      fresh << id
    end
  end
end

puts fresh
puts fresh.size
