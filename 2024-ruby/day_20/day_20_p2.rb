require 'byebug'

grid = File.readlines(ARGV[0]).map(&:strip).map(&:chars)

def find_start(grid)
  grid.each_with_index do |row, y|
    row.each_with_index do |col, x|
      return [y, x] if col == 'S'
    end
  end
  nil
end

def find_end(grid)
  grid.each_with_index do |row, y|
    row.each_with_index do |col, x|
      return [y, x] if col == 'E'
    end
  end
  nil
end

def print_grid(grid)
  grid.each do |row|
    puts row.join
  end
  nil
end

def search_path(start, end_pos, data, width, height)
  seen = Set.new data
  todo = [[0, start]]
  prev = {}

  todo.each do |dist_info|
    dist = dist_info[0]
    x, y = dist_info[1]

    if [x,y] == end_pos
      path = []
      while [x,y] != start
        path.push([x,y])
        x, y = prev[[x,y]]
      end
      path.push(start)
      return path, dist
    end

    [[x,y+1], [x,y-1], [x+1,y], [x-1,y]].each do |nx,ny|
      if !seen.include?([nx,ny]) && 0 <= nx && nx <= width && 0 <= ny && ny <= height
        todo.push([dist+1, [nx, ny]])
        seen.add([nx, ny])
        prev[[nx, ny]] = [x, y]
      end
    end
  end

  return nil
end

start_pos = find_start(grid)
end_pos = find_end(grid)

print_grid(grid)

puts "Start: #{start_pos}"
puts "End: #{end_pos}"

def find_every_possible_teleport_at_position(start, grid, cheats_allowed)
  cheats = []

  ((-1 * cheats_allowed)..cheats_allowed).each do |y|
    ((-1 * cheats_allowed)..cheats_allowed).each do |x|
      puts "Checking #{x}, #{y}"
      nx = start[1] + x
      ny = start[0] + y

      next if (x == 0 && y == 0) || (x.abs + y.abs >= 20)
      next if (nx < 0 || ny < 0) || (nx >= grid[0].size || ny >= grid.size)

      cheats.push([[start[0] + y, start[1] + x]])
    end
  end

  cheats
end

distances = []

def find_walls(grid)
  walls = Set.new
  grid.each_with_index do |row, y|
    row.each_with_index do |col, x|
      walls.add([y, x]) if col == '#'
    end
  end
  walls
end

walls = find_walls(grid)
width = grid[0].size
height = grid.size

path, original_distance = search_path(start_pos, end_pos, walls, width, height)
puts "Original Distance: #{original_distance}"
puts "Original path: #{path}"
byebug
path.each do |step|
  cheats = find_every_possible_teleport_at_position(step, grid, 2)
  cheats.each do |cheat|
    puts "Checking step #{step} with cheat #{cheat}"
    cheat.each do |pos|
      grid[pos[0]][pos[1]] = '.'
    end

    walls = find_walls(grid)

    path, distance = search_path(start_pos, end_pos, walls, width, height)
    distances.push distance

    cheat.each do |pos|
      grid[pos[0]][pos[1]] = '#'
    end
  end
end

distances.sort.each do |d|
  puts d
end

cheat_winners = distances.to_a.select { |d| (original_distance - d) >= 100 }.size
puts "Cheating distances that saved >= 100 steps: #{cheat_winners}"

puts "Done"