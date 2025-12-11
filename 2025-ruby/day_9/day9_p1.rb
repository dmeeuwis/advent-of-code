require 'byebug'

points = File.read(ARGV[0]).split("\n").map { |l| l.split(",").map { |x| x.to_i } }
max_area = 0

pairs = points.combination(2)
pairs.each do |pair|
  x1, y1 = pair[0]
  x2, y2 = pair[1]

  area = ((x2 - x1).abs + 1) * ((y2 - y1).abs + 1)

  max_area = area if area > max_area
end

puts "Maximum rectangle area: #{max_area}"
