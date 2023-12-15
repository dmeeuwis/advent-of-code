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

def slant(grid)
  height = grid.size
  width = grid[0].size

  width.times do |x|
    #puts "Column #{x}"

    loop do
      changed = 0
      (height-1).times do |h|
       #puts "Height #{h}"
        if grid[h][x] == '.' and grid[h+1][x] == 'O'
          grid[h][x] = 'O'
          grid[h+1][x] = '.'
          changed += 1
        end
      end
      break if changed == 0
    end
  end
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
slant grid
pg grid
puts
sum = count grid
puts sum
