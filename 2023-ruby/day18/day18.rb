require 'byebug'

GRID_SIZE = 1000

def pg(grid)
  grid.each do |row|
    puts row.join ""
  end 
  nil 
end

def flood_fill(grid, y, x)
  return if y < 0 || y >= grid.size
  return if x < 0 || x >= grid[0].size

  return if grid[y][x] == '#'
  grid[y][x] = '#'

  flood_fill(grid, y-1, x)
  flood_fill(grid, y+1, x)
  flood_fill(grid, y, x-1)
  flood_fill(grid, y, x+1)
end

def dig_out_count(grid)
  count = 0
  grid.each do |row|
    digging = row[0] == '#'
    row.each_with_index do |cell, index|
      if !digging && cell == '#' && index+1 < row.size && row[index+1] == '.'
        digging = true
      elsif digging && cell == '#' && index-1 < row.size && row[index+1] == '.'
        digging = false
        count += 1
      elsif cell == '.'
        if digging
          row[index] = '#'
          count += 1
        end
      end
    end
  end
  count
end

f = File.open(ARGV[0])
commands = f.readlines.map do |l|
  l =  l.chomp.split(" ")
  [l[0], l[1].to_i, l[2].tr('()', '')]
end

grid = []
GRID_SIZE.times do |row|
  grid[row] = ['.'] * GRID_SIZE
end

DIR = { 'R' => [0, 1],
        'D' => [1, 0],
        'L' => [0, -1],
        'U' => [-1, 0]
}

start = [300, 300]
grid[start[0]][start[1]] = '#'

coord = start
commands.each do |command|
  dir = DIR[command[0]]
  command[1].times do |i|
    coord[0] += dir[0]
    coord[1] += dir[1]
    grid[coord[0]][coord[1]] = '#'
  end
end

pg grid

flood_fill(grid, 301, 301)
pg grid

count = 0
grid.each do |row|
  count += row.to_a.filter { |cell| cell == '#' }.size
end

puts "Cound is #{count}"
