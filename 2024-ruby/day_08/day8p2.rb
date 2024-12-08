require 'byebug'

grid = File.readlines(ARGV[0]).map { |line| line.strip.split('') }

def print_grid(grid)
  grid.each do |row|
    puts row.join('')
  end
end

def find_nodes(grid)
  nodes = Hash.new { |h, k| h[k] = [] }
  grid.each_with_index do |row, y|
    row.each_with_index do |col, x|
      if col != '.'
        nodes[col] << [y, x]
      end
    end
  end
  nodes
end

print_grid(grid)

nodes = find_nodes(grid)
puts "Nodes: #{nodes}"

def find_antinodes(grid, nodes)
  antinodes = []
  nodes.each do |node, coords|
    every_possible_pair = coords.combination(2).to_a

    every_possible_pair.each do |pair|
      slope_y = pair[0][0] - pair[1][0]
      slope_x = pair[0][1] - pair[1][1]

      puts "Slope: #{slope_y}, #{slope_x}"

      antinode_a = [pair[0][0] + slope_y, pair[0][1] + slope_x]
      antinode_b = [pair[1][0] - slope_y, pair[1][1] - slope_x]

      # hack to reverse direction?
      if antinode_a == pair[1] || antinode_b == pair[0]
        slope_y = pair[0][0] + pair[1][0]
        slope_x = pair[0][1] + pair[1][1]
        puts "Reversed Slope: #{slope_y}, #{slope_x}"
      end

      # all antinodes in positive direction
      out_of_grid = false
      last_node = pair[0]
      while !out_of_grid
        antinode_a = [last_node[0] + slope_y, last_node[1] + slope_x]
        puts "Antinode A: #{antinode_a}"
        if antinode_a[0] < 0 || antinode_a[0] >= grid.size || antinode_a[1] < 0 || antinode_a[1] >= grid[0].size
          out_of_grid = true
        else
          antinodes.push antinode_a
        end
        last_node = antinode_a
      end

      # all antinodes in negative direction
      out_of_grid = false
      last_node = pair[1]
      while !out_of_grid
        antinode_b = [last_node[0] - slope_y, last_node[1] - slope_x]
        puts "Antinode B: #{antinode_b}"
        if antinode_b[0] < 0 || antinode_b[0] >= grid.size || antinode_b[1] < 0 || antinode_b[1] >= grid[0].size
          out_of_grid = true
        else
          antinodes.push antinode_b
        end
        last_node = antinode_b
      end
    end

    antinodes.uniq!
    puts "Antinodes: #{antinodes}"
  end
  antinodes
end

antinodes = find_antinodes(grid, nodes)
puts "Antinodes: #{antinodes}"

antennae_nodes = nodes.values.flatten(1)
puts "Antennae nodes: #{antennae_nodes}"

antinodes.concat antennae_nodes
antinodes.uniq!

antinodes.each do |antinode|
  grid[antinode[0]][antinode[1]] = "#" if grid[antinode[0]][antinode[1]] == '.'
end
print_grid grid

puts "Antinodes: #{antinodes}"
puts "Antinodes count: #{antinodes.size}"