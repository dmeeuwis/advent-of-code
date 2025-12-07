grid = File.read(ARGV[0]).split("\n").map { |line| line.split('') }

def print_grid(grid)
  grid.each do |line|
    puts line.join
  end
end

print_grid grid

start_col = grid[0].index('S')
START = [0, start_col]

beams = [ START ]
total_splits = 0

old_grid = nil

while grid != old_grid
  puts "Cycle!"

  old_grid = grid.map(&:dup)

  beams.each_with_index do |beam, i|
    #puts "Looking at beam #{i} #{beam}"

    next_pos = [beam[0]+1, beam[1]]
    next if next_pos[0] >= grid.size || next_pos[1] <= 0 || next_pos[1] >= grid[0].size

    next_space = grid[next_pos[0]][next_pos[1]]
    #puts "\tNext space: #{next_space}"
    if next_space == '.'
      grid[next_pos[0]][next_pos[1]] = '|'
      beams[i] = next_pos

      print_grid(grid)

    elsif next_space == '|'
      beams[i] = nil

    elsif next_space == '^'
      total_splits += 1
      beams[i] = nil

      split_left = [next_pos[0], next_pos[1] - 1]
      split_right = [next_pos[0], next_pos[1] + 1]

      if grid[split_left[0]][split_left[1]] == '.'
        grid[split_left[0]][split_left[1]] = '|'
        beams.push split_left
      else
        puts "Couldn't start left beam"
      end

      if grid[split_right[0]][split_right[1]] == '.'
        grid[split_right[0]][split_right[1]] = '|'
        beams.push split_right
      else
        puts "Couldn't start right beam"
      end
    end
  end

  beams.compact!
end

puts total_splits
