require 'byebug'
require 'set'
require 'colorize'

f = File.open(ARGV[0])
grid = f.readlines.map { |l| l.chomp.split("") }

RIGHT = [0, 1]
UP    = [-1, 0]
LEFT  = [0, -1]
DOWN  = [1, 0]

def pg(grid)
  grid.each do |row|
    puts row.join ""
  end 
  nil
end

def pg_energized(grid, light_x = nil, light_y = nil)
  grid.each_with_index do |row, row_i|
    row.to_a.each_with_index do |col, col_i|
      if $energized.include? [row_i, col_i]
        if row_i == light_x && col_i == light_y
          print "#".yellow
        else
          print '#'
        end
      else
        print '.'
      end
    end
    puts
  end 
  puts
  nil
end
pg grid

$energized = Set.new
$seen = Set.new

def turn grid, light_y, light_x, dir=RIGHT, turn_number=0
  puts "turn #{turn_number}: #{light_y}, #{light_x}, #{dir}"

  if light_y < 0 || light_y >= grid.size || light_x < 0 || light_x >= grid[0].size
    # beam passed out of map
    return
  end

  if $seen.include? [light_y, light_x, dir]
    # duplicate beam
    return                      
  end

  $seen.add [light_y, light_x, dir]

  $energized.add [light_y, light_x]
  #pg_energized grid, light_y, light_x

  tile = grid[light_y][light_x]
  dirs = nil

  if dir == RIGHT 
    dirs = [DOWN] if tile == "\\"
    dirs = [UP] if tile == "/"
    dirs = [UP, DOWN] if tile == "|"
    dirs = [RIGHT] if tile == "-" || tile == '.'
  elsif dir == LEFT
    dirs = [UP] if tile == "\\"
    dirs = [DOWN] if tile == "/"
    dirs = [UP, DOWN] if tile == "|"
    dirs = [LEFT] if tile == "-" || tile == '.'
  elsif dir == DOWN 
    dirs = [RIGHT] if tile == "\\"
    dirs = [LEFT] if tile == "/"
    dirs = [DOWN] if tile == "|" || tile == '.'
    dirs = [LEFT, RIGHT] if tile == "-"
  elsif dir == UP 
    dirs = [LEFT] if tile == "\\"
    dirs = [RIGHT] if tile == "/"
    dirs = [UP] if tile == "|" || tile == '.'
    dirs = [LEFT, RIGHT] if tile == "-"
  else 
    puts "Dir #{dir} not supported yet"
  end

  dirs.each do |dir|
    turn grid, light_y + dir[0], light_x + dir[1], dir, turn_number + 1
  end

end

turn(grid, 0, 0, RIGHT, 0)
pg_energized grid
puts "Energized: #{$energized.size}"
