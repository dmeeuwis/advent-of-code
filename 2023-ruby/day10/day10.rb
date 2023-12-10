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

start = find_starting_point grid
puts "Starting point is: #{start}"

adjacency = Hash.new { |h, k| h[k] = {} }

# for my input need to try both - and |
#graph = extract_graph(start, 'l', grid, adjacency)
graph = extract_graph(start, START_TILE, grid, adjacency, 0)
puts "Max steps: #{$max_steps}"
#graph = extract_graph(start, '|', grid, adjacency)

# Define a graph using an adjacency list
#graph = {
#  'A' => { 'B' => 1, 'C' => 4 },
#  'B' => { 'A' => 1, 'C' => 2, 'D' => 5 },
#  'C' => { 'A' => 4, 'B' => 2, 'D' => 1 },
#  'D' => { 'B' => 5, 'C' => 1 }
#}

# Dijkstra implementation from 
# https://medium.com/cracking-the-coding-interview-in-ruby-python-and/dijkstras-shortest-path-algorithm-in-ruby-951417829173
def dijkstra(graph, start)
  # Create a hash to store the shortest distance from the start node to every other node
  distances = {}
  # A hash to keep track of visited nodes
  visited = {}
  # Extract all the node keys from the graph
  nodes = graph.keys

  # Initially, set every node's shortest distance as infinity
  nodes.each do |node|
    distances[node] = Float::INFINITY
  end
  # The distance from the start node to itself is always 0
  distances[start] = 0

  # Loop through until all nodes are visited
  until nodes.empty?
    min_node = nil

    # Iterate through each node
    nodes.each do |node|
      # Select the node with the smallest known distance
      if min_node.nil? || distances[node] < distances[min_node]
        # Ensure the node hasn't been visited yet
        min_node = node unless visited[node]
      end
    end

    # If the shortest distance to the closest node is infinity, other nodes are unreachable. Break the loop.
    break if distances[min_node] == Float::INFINITY

    # For each neighboring node of the current node
    graph[min_node].each do |neighbor, value|
      # Calculate tentative distance to the neighboring node
      alt = distances[min_node] + value
      # If this newly computed distance is shorter than the previously known one, update the shortest distance for the neighbor
      distances[neighbor] = alt if alt < distances[neighbor]
    end

    # Mark the node as visited
    visited[min_node] = true
    # Remove the node from the list of unvisited nodes
    nodes.delete(min_node)
  end

  # Return the shortest distances from the starting node to all other nodes
  distances
end
puts "Adjacency list:"
ap adjacency
pg adjacency

distances = dijkstra(graph, start) # Outputs: {"A"=>0, "B"=>1, "C"=>3, "D"=>4}
puts "Distances from #{start}:"
ap distances

out = distances.values.max
puts "Max Distance from #{start} is #{out}"
