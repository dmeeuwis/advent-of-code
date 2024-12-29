require 'byebug'

def parse_data
  map = []
  start_pos = []
  end_pos = []

  File.open(ARGV[0]) do |f|
    f.each_line.with_index do |line, i|
      line_chunk = line.gsub("\n", "").split("")
      map.push(line_chunk)
      start_pos = [i, line_chunk.index("S")] if line.include?("S")
      end_pos = [i, line_chunk.index("E")] if line.include?("E")
    end

    f.close
  end

  [map, start_pos, end_pos]
end

DIRECTIONS = {
  'n' => [-1, 0],
  's' => [1, 0],
  'e' => [0, 1],
  'w' => [0, -1]
}

def neighbours(pos)
  neighbours = []
  y, x = pos
  DIRECTIONS.each do |dir, vector|
    vy, vx = vector 
    ny, nx = [y + vy, x + vx]

    neighbours << "#{ny},#{nx},#{dir}"
  end

  neighbours
end

def score(d1, d2)
  return 0 if d1 == d2 
  return 2000 if (d1 == "n" && d2 == "s") || (d1 == "w" && d2 == "e") || (d1 == "s" && d2 == "n") || (d1 == "e" && d2 == "w")
  1000
end

def find_min_path(map, start_pos, end_pos)
  # populate weights
  unvisited_nodes = {}

  map.each_with_index do |row, i|
    row.each_with_index do |v, j|
      if v == 'S' || v == 'E' || v == '.'
        DIRECTIONS.keys.each do |dir|
          node = "#{i},#{j},#{dir}"
          unvisited_nodes[node] = Float::INFINITY
        end
      end
    end
  end

  
  visited_nodes = {}

  start_pos_key = "#{start_pos[0]},#{start_pos[1]},e"

  # start point 0 weight 
  unvisited_nodes[start_pos_key] = 0 
  queue = [start_pos_key]

  while queue.length > 0 
    current_node = queue.min_by{|node| unvisited_nodes[node] }
    queue.delete(current_node)
    
    y, x, dir = current_node.split(",")
    next_nodes = neighbours([y.to_i, x.to_i])

    next_nodes.each do |node| 
      next if unvisited_nodes[node].nil?

      n_dir = node.split(",")[2]

      score = 1 + unvisited_nodes[current_node]
      score += score(dir, n_dir)
      score = [score, unvisited_nodes[node]].min

      unvisited_nodes[node] = score
      queue << node if unvisited_nodes[node]
    end

    visited_nodes[current_node] = unvisited_nodes[current_node]
    unvisited_nodes.delete(current_node)

    queue = queue.select{|node| unvisited_nodes[node] != nil }
  end

  min = Float::INFINITY
  DIRECTIONS.keys.each do |dir|
    key = "#{end_pos[0]},#{end_pos[1]},#{dir}"
    min = [min, visited_nodes[key]].min if visited_nodes[key]
  end

  min
end

map, start_pos, end_pos = parse_data
puts find_min_path(map, start_pos, end_pos)
