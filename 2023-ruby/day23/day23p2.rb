require 'set'
require 'byebug'

f = File.open(ARGV[0])
grid = f.readlines.map { |l| l.chomp.split "" }

def pg(grid)
  grid.each do |row|
    puts row.join ""
  end 
  nil 
end

pg grid
puts

DIRS = [ [-1, 0], [0, 1], [1, 0], [0, -1] ]
START = [0, 1]

$lengths = []
def walk(grid, pos, seen, path_length = 0)
  seen.add pos

  if pos == [ grid.size-1, grid[0].size-2]
    puts "Found the end! path-length #{path_length}"
    $lengths.push path_length
    return path_length
  end

  DIRS.each do |dir|
    n = [pos[0] + dir[0], pos[1] + dir[1]]
    next if n[0] < 0
    next if seen.include? n

    ng = grid[n[0]][n[1]] 
    next if ng == '#'
    #puts "walk: #{pos} #{path_length} => #{n} #{ng}"
    if ng == '.' || ng = '>' || ng == '<' || ng == '^' || ng == 'v'
      walk grid, n, seen.clone, path_length + 1
    end
  end
end

walk(grid, START, Set.new)
puts "Longest walk: #{$lengths.max}"
