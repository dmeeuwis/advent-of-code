require 'set'
require 'byebug'

def clone(o)
  serialized = Marshal.dump(o)
  cloned = Marshal.load(serialized)
  cloned
end

f = File.open(ARGV[0])
bricks = f.readlines.map do |l| 
  ends = l.chomp.split "~"
  p1 = ends[0].split(',').map { |x| x.to_i }
  p2 = ends[1].split(',').map { |x| x.to_i }
  [p1, p2]
end

puts bricks.inspect

expand_bricks = bricks.map do |b|
  puts "Starting brick #{b}"
  next [b[0]] if b[0] == b[1]  # single cube
  start = b[0]
  endb = b[1]

  # find differing dimension
  index = 0 if start[0] != endb[0]
  index = 1 if start[1] != endb[1]
  index = 2 if start[2] != endb[2]

  iter = clone(start)
  inter_cubes = []
  if iter[index] < endb[index]
    incr = 1
  else
    incr = -1
  end

  iter[index] += 1
  while iter[index] != endb[index]
    inter_cubes.push clone(iter)
    iter[index] += incr
  end

  final = [start] + inter_cubes + [endb]
  puts "Expanded cubes: #{final}"
  puts
  final
end

index_space = {}
expand_bricks.each_with_index do |cubes, brick_i|
  cubes.each do |cube|
    index_space[cube] = brick_i
  end
end

def can_fall? brick, brick_i, index_space
  #puts "can_fall? #{brick.inspect} #{brick_i}"
  brick.all? do |cube|
    #puts "\tcube=#{cube}"
    down_one_cube = [cube[0], cube[1], cube[2]-1]
    above_ground = cube[2]-1 >= 1
    filled = index_space[down_one_cube]
    above_ground && filled == nil || filled == brick_i
  end
end

def fall brick, brick_i, index_space
  if can_fall? brick, brick_i, index_space
    brick_orig = clone(brick)
    brick.each do |cube|
      index_space[cube] = nil
      cube[2] -= 1
      index_space[cube] = brick_i
    end
    puts "Brick #{brick_i} fell from #{brick_orig} to #{brick}."
    return true
  end
  false
end

def all_fall_down expand_bricks, index_space
  puts "all_fall_down: #{expand_bricks.inspect}, #{index_space.inspect}"
  count = 0
  expand_bricks.each_with_index do |cubes, brick_i|
    while fall(cubes, brick_i, index_space)
      count += 1
      #puts "\tWaiting on brick #{brick_i}"
    end
  end
  count
end

count = all_fall_down expand_bricks, index_space
puts "Bricks have settled: #{count}"


count = all_fall_down expand_bricks, index_space
puts "Bricks have settled again: #{count}"


p1_count = 0
expand_bricks.each_with_index do |brick, brick_i|
  expand_bricks_clone = clone(expand_bricks)
  index_space_clone = clone(index_space)
  brick_clone = clone(brick)

  puts "Deleting brick #{brick_i}"
  expand_bricks_clone.delete brick_i
  brick_clone.each do |cube|
    index_space_clone.delete cube
  end

  count = all_fall_down expand_bricks_clone, index_space_clone
  if count == 0
    puts "Brick #{brick_i} is safe to disintegrate"
    p1_count += 1
  else 
    puts "Brick #{brick_i} is NOT safe to disintegrate"
  end
end
puts "P1 count: #{p1_count}"

#depends_on = { }
#expand_bricks.each_with_index do |cubes, brick_i|
#  below_bricks = []
#  cubes.all? do |coord|
#    below_coord = [coord[0], coord[1], coord[2]-1]
#    if index_space[below_coord] != nil && index_space[below_coord] != brick_i
#      below_bricks.push index_space[below_coord]
#    end
#  end
#  depends_on[brick_i] = below_bricks
#  puts "Brick #{brick_i} above on #{depends_on[brick_i]}"
#end

#supports = Hash.new { |h, k| h[k] = [] }
#expand_bricks.each_with_index do |cubes, brick_i|
#  cubes.all? do |coord|
#    above_coord = [coord[0], coord[1], coord[2]+1]
#    if index_space[above_coord] != nil && index_space[above_coord] != brick_i
#      supports[brick_i].push index_space[above_coord]
#      puts "Brick #{brick_i} is under #{index_space[above_coord]}"
#    end
#  end
#end
#puts "Supports: #{supports.inspect}"


#p1_count = 0
#puts "P1 count: #{p1_count}"
