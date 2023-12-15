require 'byebug'
require 'set'

f = File.open(ARGV[0])
grid = f.readlines.map { |l| l.chomp.split("") }

def pg(grid)
  grid.each do |row|
    puts row.join ""
  end 
  nil
end

def slant(grid, y_dir, x_dir)
  height = grid.size
  width = grid[0].size

  width.times do |x|
    loop do
      changed = 0
      (height-1).times do |h|
       #puts "Height #{h}"
        if grid[h][x] == '.' and grid[h+y_dir][x] == 'O'
          grid[h][x] = 'O'
          grid[h+y_dir][x] = '.'
          changed += 1
        end
      end
      break if changed == 0
    end
  end
end

def slant_north grid
  slant grid, 1, 0
end

def slant_south grid
  slant grid, -1, 0
end



def count(grid)
  sum = 0
  height = grid.size
  grid.each_with_index do |row, i|
    score = height - i
    count = row.to_a.filter { |c| c == 'O' }.size
    sum += score * count
  end
  sum
end

pg grid

puts
slant_north grid
pg grid
sum = count grid
puts sum

puts

slant_south grid
pg grid
sum = count grid
puts sum
