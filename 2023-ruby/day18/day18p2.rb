require 'byebug'

GRID_SIZE = 10_000_000

def pg(grid)
  grid.each do |row|
    puts row.join ""
  end 
  nil 
end

f = File.open(ARGV[0])
commands = f.readlines.map do |l|
  l =  l.chomp.split(" ")
  [l[0], l[1].to_i, l[2].tr('()', '')]
end

CONVERT = {
  '0' => 'R',
  '1' => 'D',
  '2' => 'L',
  '3' => 'U',
}

def convert_code(input)
  digits = input[2][0..5]
  digits.gsub! '#', '0x'
  integer = Integer(digits)
  direction = input[2][6]
  command = [CONVERT[direction], integer]
end

p2commands = commands.map { |c| convert_code c }

DIR = { 'R' => [0, 1],
        'D' => [1, 0],
        'L' => [0, -1],
        'U' => [-1, 0]
}

coord = [0, 0]
vertices = [coord]
line_len = 0
p2commands.each do |command|
  dir = DIR[command[0]]
  command[1].times do |i|
    coord[0] += dir[0]
    coord[1] += dir[1]
  end
  line_len += command[1]
  vertices.push [coord[0], coord[1]]
end

puts "Verteces are: #{vertices}"

def poly_area(poly)
  area = 0.0
  for i in 0..(poly.size-2)
    j = (i + 1) % poly.size
    area += poly[i][0] * poly[j][1]
    area -= poly[j][0] * poly[i][1]
  end
  (area / 2.0).abs
end

area = poly_area vertices
puts area
line_len = (line_len + 2) / 2
puts area + line_len
