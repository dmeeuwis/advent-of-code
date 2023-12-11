require 'byebug'
require 'set'

FACTOR = 999_999

f = File.open(ARGV[0])
grid = f.readlines.map { |l| l.chomp.split("") }

def find_galaxies(grid)
  galaxies = []
  grid.each_with_index do |row, row_i|
    row.each_with_index do |col, col_i|
      galaxies.push [row_i, col_i] if col == '#'
    end
  end
  galaxies
end

galaxies = find_galaxies grid
puts "Galaxies: #{galaxies}"

def expand_universe!(grid, galaxies)
  (grid.size - 1).downto(0) do |index|
    puts "Expanding row #{index}"
    if grid[index].all?(".")
      galaxies.each do |g|
        if g[0] >= index
          print "\tExpanding galaxy #{g.inspect} => "
          g[0] += FACTOR
          puts g.inspect
        end
      end
    end
  end

  def col(grid, index)
    grid.map { |r| r[index] }
  end

  (grid[0].size - 1).downto(0) do |col_index|
    column = col(grid, col_index)
    if column.all?(".")
      puts "Expanding column #{col_index}"
      galaxies.each do |g|
        if g[1] >= col_index
          print "\tExpanding col #{g.inspect} => "
          g[1] += FACTOR
          puts g.inspect
        end
      end
    end
  end
end

def pg(grid)
  grid.each do |row|
    puts row.join ""
  end
end

def manhattan(pt1, pt2)
  (pt1[0]-pt2[0]).abs + (pt1[1]-pt2[1]).abs
end

expand_universe!(grid, galaxies)

pairs = Set.new
galaxies.each do |first|
  galaxies.each do |second|
    next if first == second
    pairs.add Set.new [first, second]
  end
end

puts "Pairs: #{pairs.size}"
puts pairs

sum = 0
pairs.each do |p|
  a = p.to_a
  dist = manhattan a[0], a[1]
  puts "Dist: #{a[0]} to #{a[1]} = #{dist}"
  sum += dist
end

puts "Sum: #{sum}"
