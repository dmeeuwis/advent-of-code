require 'byebug'

DIRECTIONS = {
  'n' => [-1, 0],
  's' => [1, 0],
  'e' => [0, 1],
  'w' => [0, -1]
}

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

def get_next_nodes(pos)
  next_nodes = []
  y, x = pos
  DIRECTIONS.each do |dir, vector|
    vy, vx = vector 
    ny, nx = [y + vy, x + vx]

    next_nodes << "#{ny},#{nx},#{dir}"
  end

  next_nodes
end

def get_score_increment(d1, d2)
  return 0 if d1 == d2 
  return 2000 if (d1 == "n" && d2 == "s") || (d1 == "w" && d2 == "e") || (d1 == "s" && d2 == "n") || (d1 == "e" && d2 == "w")
  1000
end

def part1(map, start_pos, end_pos)
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
    next_nodes = get_next_nodes([y.to_i, x.to_i])

    next_nodes.each do |node| 
      next if unvisited_nodes[node].nil?

      n_dir = node.split(",")[2]

      score = 1 + unvisited_nodes[current_node]
      score += get_score_increment(dir, n_dir)
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

  [min, visited_nodes]
end

def dfs(map, current_pos, current_weight, current_path, dir)
  y, x = current_pos.map(&:to_i)
  undir_node = "#{y},#{x}"

  if map[y][x] == "E" && $min_score == current_weight
    current_path.to_a.each{|p| $paths_taken.add(p) }
    return 
  end

  return if map[y][x] == "#" || current_weight > $min_score  || current_weight > $all_min_scores[undir_node + ",#{dir}"]

  current_path.add(undir_node)

  next_nodes = get_next_nodes([y, x])
  next_nodes.each do |next_node|
    _y, _x, _dir = next_node.split(",")
    _y = _y.to_i 
    _x = _x.to_i 

    next if current_path.include?("#{_y}#{_x}")
    weight = 1 + current_weight
    weight += get_score_increment(dir, _dir)

    dfs(map, [_y, _x],  weight, current_path.dup, _dir)
  end
   
end

def part2(map, start_pos, end_pos)
  min_score, all_min_scores = part1(map, start_pos, end_pos)
  paths_taken = Set.new([])

  dfs(map, start_pos.dup, 0, Set.new([]), "e")

  return paths_taken.to_a.length + 1
end

$min_score = Float::INFINITY
$all_min_scores = Hash.new(Float::INFINITY)

map, start_pos, end_pos = parse_data
puts part2(map, start_pos, end_pos)
