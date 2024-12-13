require 'byebug'

grid = File.readlines(ARGV[0]).map(&:strip).map(&:chars).map { |row| row.map { |v| v.to_i } }

def find_trailheads(grid)
  trailheads = []
  grid.each_with_index do |row, y|
    row.each_with_index do |col, x|
      if col == 0
        trailheads << [y, x]
      end
    end
  end
  trailheads
end

def print_grid(grid)
  grid.each do |row|
    puts row.join
  end
end

def neighbours(start, grid)
  neighbours = []
  y, x = start
  if y > 0
    neighbours << [y - 1, x]
  end
  if y < grid.size - 1
    neighbours << [y + 1, x]
  end
  if x > 0
    neighbours << [y, x - 1]
  end
  if x < grid[0].size - 1
    neighbours << [y, x + 1]
  end
  neighbours
end

@paths = []
def find_paths_from_trailhead(grid, start, curr, path)
  cur_value = grid[curr[0]][curr[1]]

  if path.size == 10 && cur_value == 9
    @paths.push({ start: start, curr: curr })
    return curr
  end

  paths = []
  neighbours = neighbours(curr, grid)

  unless neighbours.size > 0
    return []
  end

  neighbours.each do |nx|
    next if path.index(nx) # no looping paths

    if grid[nx[0]][nx[1]] == cur_value + 1
      p = path.dup
      p.push nx
      paths.concat find_paths_from_trailhead(grid, start, nx, p)
    end
  end

  paths
end

starts = find_trailheads(grid)
puts "Starts are #{starts}"
score = 0
paths = starts.each do |s|
  paths = find_paths_from_trailhead(grid, s, s, [s])
end

puts "@starts are #{@paths}"
score = @paths.size

puts "Total score is #{score}"