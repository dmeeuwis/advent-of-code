require 'byebug'

lines = File.readlines ARGV[0]
grid = lines.map { |line| line.strip.split('') }

def search_right(grid, x, y)
  grid[y][x] == 'X' &&
  grid[y][x+1] == 'M' && 
  grid[y][x+2] == 'A' &&
  grid[y][x+3] == 'S'
rescue NoMethodError
  false
end

def search_left(grid, x, y)
  grid[y][x] == 'X' &&
  grid[y][x-1] == 'M' && 
  grid[y][x-2] == 'A' &&
  grid[y][x-3] == 'S'
rescue NoMethodError
  false
end

def search_up(grid, x, y)
  grid[y][x] == 'X' &&
  grid[y-1][x] == 'M' && 
  grid[y-2][x] == 'A' &&
  grid[y-3][x] == 'S'
rescue NoMethodError
  false
end

def search_down(grid, x, y)
  grid[y][x] == 'X' &&
  grid[y+1][x] == 'M' && 
  grid[y+2][x] == 'A' &&
  grid[y+3][x] == 'S'
rescue NoMethodError
  false
end

def search_ur(grid, x, y)
  grid[y][x] == 'X' &&
  grid[y-1][x+1] == 'M' && 
  grid[y-2][x+2] == 'A' &&
  grid[y-3][x+3] == 'S'
rescue NoMethodError
  false
end

def search_dr(grid, x, y)
  grid[y][x] == 'X' &&
  grid[y+1][x+1] == 'M' && 
  grid[y+2][x+2] == 'A' &&
  grid[y+3][x+3] == 'S'
rescue NoMethodError
  false
end

def search_ul(grid, x, y)
  grid[y][x] == 'X' &&
  grid[y-1][x-1] == 'M' && 
  grid[y-2][x-2] == 'A' &&
  grid[y-3][x-3] == 'S'
rescue NoMethodError
  false
end

def search_dl(grid, x, y)
  grid[y][x] == 'X' &&
  grid[y+1][x-1] == 'M' && 
  grid[y+2][x-2] == 'A' &&
  grid[y+3][x-3] == 'S'
rescue NoMethodError
  false
end

sum = 0
0.upto(grid.size - 1) do |y|
  0.upto(grid[y].size - 1) do |x|
    if search_right(grid, x, y)
      puts "Found RIGHT at #{x}, #{y}"
      sum += 1 
    end

    if search_left(grid, x, y)
      puts "Found LEFT at #{x}, #{y}"
      sum += 1 
    end

    if search_up(grid, x, y)
      puts "Found UP at #{x}, #{y}"
      sum += 1
    end

    if search_down(grid, x, y)
      puts "Found DOWN at #{x}, #{y}"
      sum += 1 
    end

    if search_ur(grid, x, y)
      puts "Found UR at #{x}, #{y}"
      sum += 1 
    end

    if search_dr(grid, x, y)
      puts "Found DR at #{x}, #{y}"
      sum += 1 
    end

    if search_ul(grid, x, y)
      puts "Found UL at #{x}, #{y}"
      sum += 1 
    end

    if search_dl(grid, x, y)
      puts "Found DL at #{x}, #{y}"
      sum += 1 
    end
  end
end

puts "Found #{sum} matches"
exit