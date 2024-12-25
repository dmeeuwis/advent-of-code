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

def check_all_ones(grid, robots)
  grid.each_with_index do |row, row_i|
    row.each_with_index do |cell, i|
      count = robots.count { |robot| robot[0] == [i, row_i] }
      return false if count > 1
    end
  end
  true
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

100_000.times do |i|
  puts "Checking iteration #{i}"
  robots.each do |robot|
    move_robot(robot, height, width)
  end
  if check_all_ones(grid, robots)
    print_grid_numbered grid, robots
  end
end
