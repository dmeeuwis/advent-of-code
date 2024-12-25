require 'byebug'

# read lines as one big string
input = File.read ARGV[0]
parts = input.split("\n\n")

grid = parts[0].split("\n").map { |x| x.split('') }
instructions = parts[1].split("\n").join.chars

def print_grid(grid)
  grid.each do |row|
    puts row.join('')
  end
end

def move(grid, instruction, cur_char, cur_y, cur_x)
  move = 
    case instruction
    when '>'
      [0, 1]
    when '<'
      [0, -1]
    when '^'
      [-1, 0]
    when 'v'
      [1, 0]
    end

  next_space = grid[cur_y + move[0]][cur_x + move[1]]
  if next_space == '.'
    grid[cur_y][cur_x] = '.'
    cur_y += move[0]
    cur_x += move[1]
    grid[cur_y][cur_x] = cur_char

    return [cur_char, cur_y, cur_x]
  elsif next_space == 'O'
    # try to push next space
    res = move(grid, instruction, 'O', cur_y + move[0], cur_x + move[1])
    if res
      grid[cur_y][cur_x] = '.'
      cur_y += move[0]
      cur_x += move[1]
      grid[cur_y][cur_x] = cur_char
      return [cur_char, cur_y, cur_x]
    else 
      return nil
    end

  elsif next_space == '#'
    return nil
  end
end

def find_start(grid)
  grid.each_with_index do |row, y|
    row.each_with_index do |col, x|
      return [y, x] if col == '@'
    end
  end
  nil
end

cur_char = '@'
cur_y, cur_x = find_start(grid)
puts "Start: #{cur_y}, #{cur_x}"

print_grid(grid)

instructions.each do |instruction|
  #puts "Instruction: #{instruction}"
  res = move(grid, instruction, '@', cur_y, cur_x)
  if res
    cur_char, cur_y, cur_x = res
  end
  #print_grid(grid)
end

def calculate_gps(grid)
  gps = 0
  grid.each_with_index do |row, y|
    row.each_with_index do |col, x|
      if col == 'O'
        gps += 100 * y + x
      end
    end
  end
  gps
end

puts "GPS: #{calculate_gps(grid)}"