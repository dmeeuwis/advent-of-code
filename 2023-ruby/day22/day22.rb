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

bricks = bricks.sort_by { |x| x.map {|y| y[2]}.min }

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
    puts "Brick #{brick} is falling..."
    brick_orig = clone(brick)
    brick.each do |cube|
      index_space[cube] = nil
      cube[2] -= 1
      index_space[cube] = brick_i
    end
    puts "Brick fell to #{brick}"
    puts
    #puts "Check: old pos start=#{index_space[brick_orig[0]]} end=#{index_space[brick_orig[-1]]}"
    return true
  end
  false
end

def all_fall_down expand_bricks, index_space
  #puts "all_fall_down: #{expand_bricks.inspect}, #{index_space.inspect}"
  count = 0
  expand_bricks.each_with_index do |cubes, brick_i|
    fall = false
    while fall(cubes, brick_i, index_space)
      fall = true
      #puts "\tWaiting on brick #{brick_i}"
    end
    count += 1 if fall
  end
  count
end

count = all_fall_down expand_bricks, index_space
puts "Bricks have settled: #{count}"


count = all_fall_down expand_bricks, index_space
puts "Bricks have settled again: #{count}"


p1_count = 0
p2_count = 0
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
    p2_count += count
  end
end
puts "P1 count: #{p1_count}"
puts "P2 count: #{p2_count}"
