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
stack = []
stack.push [START, Set.new, 0]
def walk(grid, stack)
  while !stack.empty?
    puts stack.size if stack.size % 100_000 == 0
    pos, seen, path_length = stack.pop
    seen.add pos

    if pos == [ grid.size-1, grid[0].size-2]
      puts "Found the end! path-length #{path_length}"
      $lengths.push path_length
    end

    DIRS.each do |dir|
      n = [pos[0] + dir[0], pos[1] + dir[1]]
      next if n[0] < 0
      next if n[0] >= grid.size
      next if seen.include? n
      #puts n

      ng = grid[n[0]][n[1]] 
      next if ng == '#'
      #puts "walk: #{pos} #{path_length} => #{n} #{ng}"
      if ng == '.' || ng = '>' || ng == '<' || ng == '^' || ng == 'v'
        stack.push [n, seen.clone, path_length + 1]
      end
    end
  end
end

walk(grid, stack)
puts "Longest walk: #{$lengths.max}"
