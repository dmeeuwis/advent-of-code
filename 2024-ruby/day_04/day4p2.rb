require 'byebug'

lines = File.readlines ARGV[0]
grid = lines.map { |line| line.strip.split('') }

# M . S
# . A .
# M . S
def search_mas_right(grid, x, y)
  grid[y][x] == 'M' &&
  grid[y+1][x+1] == 'A' && 
  grid[y+2][x+2] == 'S' &&
  grid[y+2][x] == 'M' && 
  grid[y][x+2] == 'S'
rescue NoMethodError
  false
end

# M . M
# . A .
# S . S
def search_mas_down(grid, x, y)
  grid[y][x] == 'M' &&
  grid[y+1][x+1] == 'A' && 
  grid[y+2][x+2] == 'S' &&
  grid[y][x+2] == 'M' && 
  grid[y+2][x] == 'S'
rescue NoMethodError
  false
end

# S . S
# . A .
# M . M
def search_mas_up(grid, x, y)
  grid[y][x] == 'S' &&
  grid[y+1][x+1] == 'A' && 
  grid[y+2][x+2] == 'M' &&
  grid[y][x+2] == 'S' && 
  grid[y+2][x] == 'M'
rescue NoMethodError
  false
end


# S . M
# . A .
# S . M
def search_mas_left(grid, x, y)
  grid[y][x] == 'S' &&
  grid[y+1][x+1] == 'A' && 
  grid[y+2][x+2] == 'M' &&
  grid[y][x+2] == 'M' && 
  grid[y+2][x] == 'S'
rescue NoMethodError
  false
end


sum = 0
0.upto(grid.size - 1) do |y|
  0.upto(grid[y].size - 1) do |x|
    if search_mas_right(grid, x, y)
      puts "Found MAS RIGHT at #{x}, #{y}"
      sum += 1 
    end

    if search_mas_left(grid, x, y)
      puts "Found MAS LEFT at #{x}, #{y}"
      sum += 1 
    end

    if search_mas_up(grid, x, y)
      puts "Found MAS UP at #{x}, #{y}"
      sum += 1
    end

    if search_mas_down(grid, x, y)
      puts "Found MAS DOWN at #{x}, #{y}"
      sum += 1 
    end
  end
end

puts "Found #{sum} matches"
exit