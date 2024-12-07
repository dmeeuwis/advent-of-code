require 'byebug'

grid = File.readlines(ARGV[0]).map(&:strip).map(&:chars)

def find_start(grid)
  grid.each_with_index do |row, y|
    row.each_with_index do |col, x|
      return [y, x] if col == '^'
    end
  end
  nil
end

def print_grid(grid)
  grid.each do |row|
    puts row.join
  end
end

start = find_start(grid)
puts "Start: #{start}"

def move(grid, start, animated)
  def check_oob(y, x, grid)
    if y >= grid.size || x >= grid[0].size || y < 0 || x < 0
      raise "Out of bounds at #{y}, #{x}"
      print_grid grid
    end
  end

  history = Set.new
  while true
    y, x = start
    case grid[y][x]
    when '^'
      grid[y][x] = 'X'
      y -= 1
      check_oob y, x, grid

      if grid[y][x] == '#'
        y += 1
        x += 1
        grid[y][x] = '>'
      else
        grid[y][x] = '^'
      end
    when 'v'
      grid[y][x] = 'X'
      y += 1
      check_oob y, x, grid

      if grid[y][x] == '#'
        y -= 1
        x -= 1
        grid[y][x] = '<'
      else
        grid[y][x] = 'v'
      end

    when '<'
      grid[y][x] = 'X'
      x -= 1
      check_oob y, x, grid

      if grid[y][x] == '#'
        x += 1
        y -= 1
        grid[y][x] = '^'
      else 
        grid[y][x] = '<'
      end
    when '>'
      grid[y][x] = 'X'
      x += 1
      check_oob y, x, grid

      if grid[y][x] == '#'
        x -= 1
        y += 1
        grid[y][x] = 'v'
      else
        grid[y][x] = '>'
      end
    end

    if history.include? [y, x, grid[y][x]]
      raise "Loop detected at #{y}, #{x}"
    end

    history.add [y, x, grid[y][x]]

    start = [y, x]
    if animated
      puts "Moved to #{start}"
      print_grid grid
    # sleep 0.5
      puts
      puts
    end
  end
end

orig_grid = grid.map(&:dup)

print_grid grid
begin
  move(grid, start, false)
rescue => e
  puts e.message
end

sum = 0
moved = []
grid.each_with_index do |row, y|
  row.each_with_index do |col, x|
    if col == 'X'
      sum += 1
      moved.push [y, x]
    end
  end
end

moved.reject! { |m| m == start }

print_grid grid

puts "Saw #{sum} Xs"
loops = 0
moved.each_with_index do |m, i|
  puts "Blocking #{m}"
  grid = orig_grid.map(&:dup)
  grid[m[0]][m[1]] = '#'
  begin
   move(grid, start, false)
  rescue => e
    next unless e.message.start_with? "Loop detected"

    puts e.message
    puts "Saw a loop after blocking #{m}"
    print_grid grid
    loops += 1
  end
end

puts "Saw #{loops} loops"
