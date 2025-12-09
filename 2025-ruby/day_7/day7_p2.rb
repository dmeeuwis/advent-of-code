grid = File.read(ARGV[0]).split("\n").map { |line| line.split('') }

start_col = grid[0].index('S')
rows = grid.size
cols = grid[0].size

particles = Hash.new(0)
particles[[0, start_col]] = 1

completed = 0

loop do
  break if particles.empty?

  new_particles = Hash.new(0)

  particles.each do |(row, col), count|
    next_row = row + 1

    if next_row >= rows
      completed += count
      next
    end

    next_col = col
    next_cell = grid[next_row][next_col]

    if next_cell == '.' || next_cell == 'S'
      new_particles[[next_row, next_col]] += count

    elsif next_cell == '^'
      left_col = next_col - 1
      right_col = next_col + 1

      if left_col >= 0 && left_col < cols
        new_particles[[next_row, left_col]] += count
      else
        completed += count
      end

      if right_col >= 0 && right_col < cols
        new_particles[[next_row, right_col]] += count
      else
        completed += count
      end

    elsif next_cell == '|'
      completed += count
    end
  end

  particles = new_particles
end

puts completed
