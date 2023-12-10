require 'byebug'
require 'pp'
require 'awesome_print'
require 'colorize'

f = File.open(ARGV[0])
grid = f.readlines.map { |l| l.chomp.split("") }
$grid = grid

def find_starting_point(grid)
  grid.each_with_index do |row, i|
    row.each_with_index do |col, j|
      return [i, j] if grid[i][j] == 'S'
    end
  end
end

START_TILE = ARGV[1]
puts "Starting tile: #{START_TILE}"

TILES = { # y, x
  "|" => [[-1, 0], [1, 0]],
  "-" => [[0, -1], [0, 1]],
  "L" => [[0,  1], [-1, 0]],
  "J" => [[0, -1], [-1, 0]],
  "7" => [[0, -1], [1, 0]],
  "F" => [[0,  1], [1, 0]],
}

def pg(adjacency)
  $grid.each_with_index do |row, row_i|
    row.each_with_index do |col, col_i|
      if adjacency[[row_i, col_i]].size > 0
        print col.red.bold
      else 
        print col
      end
    end
    puts
  end
  nil
end

$max_steps = 0
def extract_graph(coord, start_pipe, grid, adjacency, steps)
  $max_steps = steps if steps > $max_steps
  return adjacency if adjacency[coord].size > 0

  tile = start_pipe || grid[coord[0]][coord[1]]
  nexts = TILES[tile]
  next_first = [coord[0] + nexts[0][0], coord[1] + nexts[0][1]] 
  next_second = [coord[0] + nexts[1][0], coord[1] + nexts[1][1]]
  adjacency[coord][next_first] = 1
  adjacency[coord][next_second] = 1

  extract_graph(next_first, nil, grid, adjacency, steps + 1)
  extract_graph(next_second, nil, grid, adjacency, steps + 1)

  adjacency
end  

def count_left coord, grid, adjacency
  count = 0
  coord[1].times do |i|
    if adjacency[[coord[0],i]].size > 0
     count += 1
    end 
  end
  count
end

def count_right coord, grid, adjacency
  count = 0
  width = coord[0].size
  (width - coord[1]).times do |i|
    if adjacency[[coord[0],coord[1] + i]].size > 0
     count += 1
    end 
  end
  count
end

def in_or_out(coord, grid, adjacency)
  if adjacency[ [coord[0],coord[1]] ].size > 0
    :on
  else
    count_l = count_left coord, grid, adjacency
    count_r = count_right coord, grid, adjacency
    count = count_l + count_r
    label = count % 2 == 0 ? :out : :in
    puts "For #{coord} saw #{count_l} to the left, #{count_r} to the right => #{label}"
    label
  end
end

start = find_starting_point grid
puts "Starting point is: #{start}"

adjacency = Hash.new { |h, k| h[k] = {} }
pg adjacency
graph = extract_graph(start, START_TILE, grid, adjacency, 0)
puts "Max Distance from #{start} is #{$max_steps / 2}"

in_count = 0
out_count = 0
pipe_count = 0
grid.each_with_index do |row, row_i|
  grid[row_i].each_with_index do |col, col_i|
    i = in_or_out([row_i, col_i], grid, adjacency)
    in_count += 1 if i == :in
    out_count += 1 if i == :out
    pipe_count += 1 if i == :on
  end
end

puts "Total tiles: #{grid[0].size * grid[1].size}"
puts "Out tiles: #{out_count}"
puts "In tiles: #{in_count}"
puts "Pipe tiles: #{pipe_count}"

puts "Part 2: I binary searched my best answer against the website's higher/lower tip to figure out it was 541."
