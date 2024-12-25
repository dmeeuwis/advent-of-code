require 'byebug'

map = File.readlines(ARGV[0]).map { |row| row.strip.split('') }

def print_map(map)
  map.each do |row|
    puts row.join
  end
end

def next_square(map, current)
  y, x = current
  if x == map[0].size - 1
    [y + 1, 0]
  else
    [y, x + 1]
  end
end

def last_square?(map, start)
  y, x = start
  y == map.size - 1 && x == map[0].size - 1
end

def neighbours(start, map)
  neighbours = []
  y, x = start
  if y > 0
    neighbours << [y - 1, x]
  end
  if y < map.size - 1
    neighbours << [y + 1, x]
  end
  if x > 0
    neighbours << [y, x - 1]
  end
  if x < map[0].size - 1
    neighbours << [y, x + 1]
  end
  neighbours
end


# takes a map, returns a hash of coords pointing to the region they belong to
def find_regions(map, start = [0, 0])
  return if last_square?(map, start)
  unless @regions[start]
    stack = []
    plant = map[start[0]][start[1]]
    @regions[start] = start
    neighbours = neighbours(start, map)
    puts "Neighbours of #{start}: #{neighbours}"
    neighbours.each do |n|
      stack.push n
    end

    while !stack.empty?
      coord = stack.pop
      next if @regions[coord]

      puts "Checking #{coord} #{map[coord[0]][coord[1]]} == #{plant} ?"
      if map[coord[0]][coord[1]] == plant
        puts "Adding #{coord} to #{plant} region #{start}"
        @regions[coord] = start
        neighbours = neighbours(coord, map)
        neighbours.each do |n|
          stack.push n
        end
      end
    end
  end

  find_regions(map, next_square(map, start))
end
@regions = Hash.new
find_regions(map)

puts "Found regions:\n#{@regions}"

print_map map

areas = Hash.new { |h, k| h[k] = 0 }
perimeters = Hash.new { |h, k| h[k] = 0 }

map.each_with_index do |row, y|
  row.each_with_index do |plant, x|
    puts "Plant: #{plant}, y: #{y}, x: #{x}"
    region = @regions[[y, x]]
    areas[[plant, region]] += 1

    # check left
    if x == 0 || map[y][x - 1] != plant
      perimeters[[plant, region]] += 1
    end

    # check up
    if y == 0 || map[y-1][x] != plant
      perimeters[[plant, region]] += 1
    end

    # check right
    if x == (map[0].size-1) || map[y][x+1] != plant
      perimeters[[plant, region]] += 1
    end

    # check down
    if y == (map.size-1) || map[y+1][x] != plant
      perimeters[[plant, region]] += 1
    end
  end
end

price = 0
areas.keys.each do |plant|
  cost = areas[plant] * perimeters[plant]
  price += cost
  puts "#{plant}: Area #{areas[plant]}, Perimeter #{perimeters[plant]}, cost #{cost}"
end

puts "Total cost: #{price}"