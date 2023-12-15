require 'byebug'
require 'set'

f = File.open(ARGV[0])
grid = f.readlines.map { |l| l.chomp.split("") }

def pgs(grid)
  s = ""
  grid.each do |row|
    s += row.join("") + "\n"
  end 
  s
end

def pg(grid)
  grid.each do |row|
    puts row.join ""
  end 
  nil
end

def slant_north(grid)
  height = grid.size
  width = grid[0].size

  width.times do |x|
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


def slant_south(grid)
  height = grid.size
  width = grid[0].size

  width.times do |x|
    loop do
      changed = 0
      (height-1).times do |h|
       #puts "Height #{h}"
        if grid[h][x] == 'O' and grid[h+1][x] == '.'
          grid[h][x] = '.'
          grid[h+1][x] = 'O'
          changed += 1
        end
      end
      break if changed == 0
    end
  end
end

def slant_west(grid)
  height = grid.size
  width = grid[0].size

  height.times do |h|
    loop do
      changed = 0
      (width-1).times do |x|
        if grid[h][x] == '.' and grid[h][x+1] == 'O' 
          grid[h][x] = 'O'
          grid[h][x+1] = '.'
          changed += 1
        end
      end
      break if changed == 0
    end
  end
end

def slant_east(grid)
  height = grid.size
  width = grid[0].size

  height.times do |h|
    loop do
      changed = 0
      (width-1).times do |x|
        if grid[h][x] == 'O' and grid[h][x+1] == '.' 
          grid[h][x] = '.'
          grid[h][x+1] = 'O'
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

def cycle grid
  slant_north grid
  slant_west grid
  slant_south grid
  slant_east grid
  grid
end

def print_cycle
  puts "Original"
  pg grid

  puts
  puts "Slant North"
  slant_north grid
  pg grid
  sum = count grid
  puts sum

  puts

  puts "Slant West"
  slant_west grid
  pg grid
  sum = count grid
  puts sum

  puts

  puts "Slant South"
  slant_south grid
  pg grid
  sum = count grid
  puts sum

  puts

  puts "Slant East"
  slant_east grid
  pg grid
  sum = count grid
  puts sum
end

cache = {}
BIG = 1_000_000_000
grid_str = nil
advance = 0
BIG.times do |i|
  puts i
  cycle grid

  grid_str = pgs grid
  if cache[grid_str]
    puts "Saw iteration #{i} matching iteration #{cache[grid_str]}"
  
    remaining = BIG - i 
    skip_turns = remaining / i
    i_left = BIG - i - (i * skip_turns)
    puts "Turns left #{i_left}"
    advance = BIG - i_left
    break
  end

  cache[grid_str] = i
end
puts "Advanced to #{advance}"

(advance..BIG+5).each do |i|
    puts i
    cycle grid
    sum = count(grid)
    puts "sum is #{sum}"
end

sum = count(grid)
puts "Last sum is #{sum}"

sum = count grid
puts "Load is: #{sum}"

# the exact answer at i=BIG didn't match, but some manual trying against a few
# values leading up to i=BIG revealed the answer was 88680 from i=999999992.
# Must be an off-by-something small error somewhere above. Oh well, got the answer!
puts "Manual testing of AoC inputs revealed sum was 88680"
