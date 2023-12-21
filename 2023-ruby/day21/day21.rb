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
      grid[row_i][i] = 'O'
      return [row_i, i]
    end
  end
  nil
end


pg grid
start = find_start grid
puts "Start is #{start}"
puts

def inr(pos, grid)
  return pos[0] >= 0 && pos[0] < grid.size && pos[1] >= 0 && pos[1] < grid[0].size
end

poses = [start]
STEPS = 64
STEPS.times do |i|
  next_pos = []

  # clear the grid of the current standing spots so they can be re-stood on
  poses.each do |pos|
    grid[pos[0]][pos[1]] = '.'
  end

  while pos = poses.pop
    puts "Stepping from #{pos}"
    step_u = [pos[0]-1, pos[1]]
    if inr(step_u, grid) && grid[step_u[0]][step_u[1]] == '.'
      puts "Step to #{step_u}"
      grid[step_u[0]][step_u[1]] = 'O'
      next_pos.push step_u
     #pg grid
     #puts
    end

    step_r = [pos[0], pos[1]+1]
    if inr(step_r, grid) && grid[step_r[0]][step_r[1]] == '.'
      puts "Step to #{step_r}"
      grid[step_r[0]][step_r[1]] = 'O' 
      next_pos.push step_r
     #pg grid
     #puts
    end

    step_d = [pos[0]+1, pos[1]]
    if inr(step_d, grid) && grid[step_d[0]][step_d[1]] == '.'
      puts "Step to #{step_d}"
      grid[step_d[0]][step_d[1]] = 'O'
      next_pos.push step_d
     #pg grid
     #puts
    end

    step_l = [pos[0], pos[1]-1]
    if inr(step_l, grid) && grid[step_l[0]][step_l[1]] == '.'
      puts "Step to #{step_l}"
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
  puts "=========== End of step  #{i} =========="
  pg grid
end

count = 0

grid.each do |row|
  row.each do |c|
    count += 1 if c == 'O'
  end
end

puts count
