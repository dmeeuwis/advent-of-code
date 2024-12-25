require 'byebug'

lines = File.readlines ARGV[0]

def read_robot(line)
  line.split(' ').map { |x| x[2..].split(',').map { |y| y.to_i } }
end

def make_grid(height, width)
  height.times.map { |x| ['.'] * width }
end

def print_grid(grid)
  grid.each do |row|
    puts row.join('')
  end
end


def print_grid_numbered(grid, robots)
  grid.each_with_index do |row, row_i|
    row.each_with_index do |cell, i|
      count = robots.count { |robot| robot[0] == [i, row_i] }
      if count == 0
        print '.'
      else 
        print count
      end
    end
    print "\n"
  end
end

def move_robot(robot, height, width)
  robot[0][0] = (robot[0][0] + robot[1][0]) % width
  robot[0][1] = (robot[0][1] + robot[1][1]) % height
end

if ARGV[0] == 'input.txt'
  width, height = 103, 101
else 
  width, height = 11, 7
end

grid = make_grid(height, width)
robots = lines.map { |line| read_robot(line) }
print_grid_numbered grid, robots
puts "Robots: #{robots}"

100.times do |i|
  robots.each do |robot|
    move_robot(robot, height, width)
  end
  print_grid_numbered grid, robots
  puts
end

#quadrants = [
#  [ [0, 0], [4, 2] ],
#  [ [6, 0], [10, 2] ],
#  [ [0, 4], [4, 7] ],
#  [ [6, 4], [10, 7] ],
#]

quadrants = [
  [ [0, 0], [width / 2 - 1, height / 2 - 1] ],
  [ [width / 2 + 1, 0], [width - 1, height / 2 - 1] ],
  [ [0, height / 2 + 1], [width / 2 - 1, height - 1] ],
  [ [width / 2 + 1, height / 2 + 1], [width - 1, height - 1] ],
]

quadrant_counts = quadrants.map do |quad| 
  start_x, start_y = quad[0]
  end_x, end_y = quad[1]

  robots.count do |robot| 
    rob_x = robot[0][0]
    rob_y = robot[0][1]
    rob_x >= start_x && rob_x <= end_x && rob_y >= start_y && rob_y <= end_y
  end
end
puts "Quadrant counts: #{quadrant_counts}"
puts "Quadrant multiple: #{quadrant_counts.reduce(:*)}"
