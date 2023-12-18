require 'algorithms'
require 'set'
require 'byebug'

f = File.open(ARGV[0])
ll = f.readlines.map { |l| l.chomp.split("").map { |i| i.to_i } }

DIRS = [[0, 1], [1, 0], [0, -1], [-1, 0]]

def in_range(pos, arr)
  pos[0] >= 0 && pos[0] < arr.size && pos[1] >= 0 && pos[1] < arr[0].size
end

def run(ll, mindist, maxdist)
  q = Containers::PriorityQueue.new
  q.push [0, 0, 0, -1], 0
  seen = Set.new()
  costs = {}

  while !q.empty? do
    cost, x, y, dd = q.pop
    #puts "Pop: #{cost} #{x} #{y} dd=#{dd}"

    # goal!
    if x == ll.size - 1 and y == ll[0].size - 1
      ##uts "We did it! #{cost}"
      return cost
    end

    next if seen.include? [x, y, dd]
    seen.add([x, y, dd])

    (0..3).each do |direction|

      costincrease = 0
      next if direction == dd or (direction + 2) % 4 == dd

      (1..maxdist).each do |distance|
        nx = x + DIRS[direction][0] * distance
        ny = y + DIRS[direction][1] * distance
        if in_range([nx, ny], ll)
          costincrease += ll[nx][ny]

          next if distance < mindist

          nc = cost + costincrease
          next if (costs[ [nx, ny, direction] ] || 1e100) <= nc

          costs[[nx, ny, direction]] = nc
          q.push([nc, nx, ny, direction], -1 * nc)
          #puts "\tPushed with cost #{-1*nc} #{[nc, nx, ny, direction]}"
        end
      end
    end
  end

  return -1
end

puts(run(ll, 1, 3))
puts(run(ll, 4, 10))
