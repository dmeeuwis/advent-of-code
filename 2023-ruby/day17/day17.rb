require 'byebug'
require 'set'
require 'colorize'

def pg(grid)
  grid.each do |row|
    puts row.join ""
  end 
  nil
end

DIRS = [ 
    [ 1,  0], # down
    [ 0,  1], # right
    [ 0, -1], # left
    [-1,  0], # up
]

def target grid
  [grid.size-1, grid[0].size-1]
end

def turn(grid, y, x, dir, steps_taken, positions, heat_loss)
  #puts "#{y}, #{x}, #{dir}, #{heat_loss} #{steps_taken.size}, #{positions.inspect}"
  if [y, x] == target(grid)
    puts "Reached exit in #{steps_taken.size} steps! #{[[heat_loss], steps_taken].inspect}"
    return [heat_loss]
  end

  ways = []
  DIRS.each do |next_dir|
    # never go back
    if (dir[0] != 0 && dir[0] == -1 * next_dir[0]) || (dir[1] != 0 && dir[1] == -1 * next_dir[1])
     # puts "Can't go back #{dir} !=> #{next_dir}"
      next
    end

    ny = y + next_dir[0]
    nx = x + next_dir[1]

    # don't go out of map
    if nx < 0 || ny < 0 || nx >= grid[0].size || ny >= grid.size
      #puts "Can't go out of grid #{y}, #{x} !=> #{ny}, #{nx}"
      next
    end

    # can't go more than 3 times in the same dir
    if dir == next_dir && steps_taken.size >= 3 &&
      steps_taken[-1] == dir && steps_taken[-2] == dir && steps_taken[-3] == dir
      next
    end

    if !(positions.index([ny, nx]).nil?)
      #puts "Can't repeat a step [#{ny} #{nx}] #{positions.inspect}"
      next
    end
    #next if $seen.include? [ny, nx, next_dir]
    #$seen.add [ny, nx, next_dir] # ignores 3 steps taken! Problem?

    ways += turn(grid, ny, nx, next_dir, steps_taken + [next_dir], positions + [[ny, nx]], heat_loss + grid[ny][nx])
  end

  ways
end


f = File.open(ARGV[0])
grid = f.readlines.map { |l| l.chomp.split("").map { |i| i.to_i } }

pg grid
all_ways = turn(grid, 0, 0, [0, 0], [ [0,0] ], [ [0,0] ], 0)

puts "Found #{all_ways.min} ways to get to exit."
puts all_ways.inspect
puts "Min heatloss is #{all_ways.min}"
