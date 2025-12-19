data = File.read(ARGV[0])

def count_cells(lines)
  lines.sum { |line| line.count('#') }
end

sections = data.split("\n\n")

shape_section, region_section = sections.partition do |section|
  lines = section.strip.split("\n")
  lines.first =~ /^(\d+):$/
end

shapes = shape_section.map do |section|
  lines = section.strip.split("\n")
  index = lines.first.match(/^(\d+):$/)[1].to_i
  shape_lines = lines[1..]
  [index, count_cells(shape_lines)]
end.to_h

count = region_section.sum do |section|
  section.strip.split("\n").count do |line|
    next unless line =~ /^(\d+)x(\d+): (.+)$/

    width = $1.to_i
    height = $2.to_i
    counts = $3.split.map(&:to_i)
    grid_area = width * height
    total_cells = counts.each_with_index.sum { |c, shape_idx| c * shapes[shape_idx] }
    total_cells <= grid_area
  end
end

puts count
