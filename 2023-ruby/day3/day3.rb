require 'set'
require 'byebug'

f = File.open(ARGV[0])
lines = f.readlines
grid = lines.map { |l| l.chomp.split("") }
MAP_WIDTH = grid[0].length
MAP_HEIGHT = grid.length

def add_if_positive(set, x, y)
  if x >= 0 && y >= 0 && x < MAP_WIDTH && y < MAP_HEIGHT
    set.add [x, y]
  end
end

def add_if_on_grid(cell, set, i, j)
    add_if_positive(set, i-1, j-1) # ul
    add_if_positive(set, i-1, j)   # u
    add_if_positive(set, i-1, j+1) # ur
    add_if_positive(set, i, j-1)   # l
    add_if_positive(set, i, j+1)   # r
    add_if_positive(set, i+1, j-1) # dl
    add_if_positive(set, i+1, j)   # d
    add_if_positive(set, i+1, j+1) # dr
end

things = []
open_thing = { name: "", coords: [] }
adjacency_set = Set.new

grid.each_with_index do |row, i|
  row.each_with_index do |cell, j|
    if (cell =~ /[0-9]/) == 0
      open_thing[:coords].push [i, j]
      open_thing[:name] += cell
      next
    end

    if open_thing[:coords].size > 0  then
      things.push open_thing
      open_thing = { name: "", coords: []}
    end

    if cell != '.'
      add_if_on_grid(cell, adjacency_set, i, j)
    end
  end
end

puts things.inspect
parts = Set.new
not_parts = Set.new
things.each do |thing|
  is_part = false
  thing[:coords].each do |coord|
    if adjacency_set.member? coord
      puts "Found a part! #{thing[:name]}"
      is_part = true
    end

    if is_part
      parts.add thing
    else
      not_parts.add thing
    end
  end
end

sum = 0
parts.each do |part|
  sum += part[:name].to_i
end

puts "Parts are: #{parts.inspect}"
puts "Not-parts aree: #{not_parts.inspect}"

puts "Sum is #{sum}"
byebug
puts