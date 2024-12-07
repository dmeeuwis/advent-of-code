
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

def move(grid, start)
  while true
    y, x = start
    case grid[y][x]
    when '^'
      grid[y][x] = 'X'
      y -= 1

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

      if grid[y][x] == '#'
        x -= 1
        y += 1
        grid[y][x] = 'v'
      else
        grid[y][x] = '>'
      end
    end


    start = [y, x]
    puts "Moved to #{start}"
    print_grid grid
    puts
    puts
  end

rescue NoMethodError

end

print_grid grid
move(grid, start)

sum = 0
grid.each do |row|
  row.each do |col|
    sum += 1 if col == 'X'
  end
end

puts "Saw #{sum} Xs"
exit 0
