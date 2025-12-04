require 'byebug'

grid = File.read(ARGV[0]).split("\n").map { |x| x.split('') }

NEIGHBOURS = [ [-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1] ]

def count_neighbours(grid, pos)
  count = 0
  NEIGHBOURS.each do |diff|
#    byebug if pos == [0,2]
    check_y = diff[0] + pos[0]
    check_x = diff[1] + pos[1]

    next if check_y < 0 || check_x < 0 || check_x >= grid[0].size || check_y >= grid.size

    if grid[check_y][check_x] == '@'
      count += 1
    end
  end

  count
end

reachable = 0
(0..(grid.size-1)).each do |y|
  (0..(grid[0].size-1)).each do |x|
    next unless grid[y][x] == '@'

    count = count_neighbours(grid, [y, x])
    puts "Checking: #{y}, #{x} => #{count}"
    if count < 4
      reachable += 1
      puts "\t[#{y}, #{x}] has #{count}"
    end
  end
end

puts reachable
