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

def find_start(grid)
  grid.each_with_index do |row, row_i|
    i = row.index('S')
    if i
      grid[row_i][i] = '.'
      return [row_i, i]
    end
  end
  nil
end


def expand_grid(grid, start_point)
  ng = Array.new(grid.size*3)
  ng.each_with_index do |nng, nng_i|
    nng = [","] * grid.size * 3
    ng[nng_i] = nng
  end

  3.times do |i|
    3.times do |ii|
      startx = i * grid.size
      starty = ii * grid[i].size
      #puts "Starting grid #{i},#{ii} at #{startx},#{starty}"

      grid.each_with_index do |row, y_i|
        row.each_with_index do |cell, x_i|
          ng[starty + y_i][startx + x_i] = cell
        end
      end
    end
  end
  nstart = [grid.size + start_point[0], grid[0].size + start_point[1]]
  [ng, nstart]
end

start = find_start grid
grid, start = expand_grid(grid, start)
puts "Expand!"
grid, start = expand_grid(grid, start)
puts "Expand!"
grid, start = expand_grid(grid, start)
puts "Expand!"
grid, start = expand_grid(grid, start)
puts "Expand all done!"
grid[start[0]][start[1]] = 'O'

def inr(pos, grid)
  return pos[0] >= 0 && pos[0] < grid.size && pos[1] >= 0 && pos[1] < grid[0].size
end

def count_steps(grid)
  count = 0
  (0..(grid.size-1)).each do |y|
    (0..(grid.size-1)).each do |x|
      count += 1 if grid[y][x] == 'O'
    end
  end
  count
end

poses = [start]
STEPS = ARGV[1].to_i
puts "Steps: #{STEPS}"
STEPS.times do |i|
  next_pos = []

  # clear the grid of the current standing spots so they can be re-stood on
  poses.each do |pos|
    grid[pos[0]][pos[1]] = '.'
  end

  while pos = poses.pop
    #puts "Stepping from #{pos}"
    step_u = [pos[0]-1, pos[1]]
    if inr(step_u, grid) && grid[step_u[0]][step_u[1]] == '.'
      #puts "Step to #{step_u}"
      grid[step_u[0]][step_u[1]] = 'O'
      next_pos.push step_u
     #pg grid
     #puts
    end

    step_r = [pos[0], pos[1]+1]
    if inr(step_r, grid) && grid[step_r[0]][step_r[1]] == '.'
      #puts "Step to #{step_r}"
      grid[step_r[0]][step_r[1]] = 'O' 
      next_pos.push step_r
     #pg grid
     #puts
    end

    step_d = [pos[0]+1, pos[1]]
    if inr(step_d, grid) && grid[step_d[0]][step_d[1]] == '.'
      #puts "Step to #{step_d}"
      grid[step_d[0]][step_d[1]] = 'O'
      next_pos.push step_d
     #pg grid
     #puts
    end

    step_l = [pos[0], pos[1]-1]
    if inr(step_l, grid) && grid[step_l[0]][step_l[1]] == '.'
      #puts "Step to #{step_l}"
      grid[step_l[0]][step_l[1]] = 'O' 
      next_pos.push step_l
     #pg grid
     #puts
    end

    #grid[pos[0]][pos[1]] = '.'
    #puts "Stepped off #{pos}"
    #pg grid
    #puts
  end
  poses = next_pos
#  puts "=========== End of step  #{i} =========="
#  pg grid
   puts "Steps=#{i} count=#{count_steps grid}"
end

count = 0

puts count
