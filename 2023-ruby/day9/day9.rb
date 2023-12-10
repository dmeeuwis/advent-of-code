require 'byebug'


def differences(dline)
  diffs = []
  prev = nil
  dline.each do |el|
    diffs.push(el - prev) if !prev.nil?
    prev = el
  end
  diffs
end

def differences_triangle(data)
  all_lines = []
  data.each do |dline|
    lines = [dline]
    diff = dline
    while !diff.all? 0
      diff = differences(diff)
      lines.push diff
    end
    all_lines.push lines
  end
  all_lines
end

def extrapolate(dset)
  data = dset.reverse
  data[0].append 0
  (1..data.size-1).each do |i|
    data[i].push "*"
    data[i][-1] = data[i-1][-1] + data[i][-2]
  end
  data.reverse
end
  
f = File.open(ARGV[0])
data = f.readlines.map { |l| l.chomp.split(" ").map &:to_i }
puts "puzzles: #{data}"
tri = differences_triangle(data)
exp = tri.map { |t| extrapolate(t) }

predictions = exp.map { |e| e[0][-1] }
sum = predictions.sum
puts sum


f = File.open(ARGV[0])
data = f.readlines.map { |l| l.chomp.split(" ").map(&:to_i).reverse }
puts "p2 puzzles: #{data}"
tri = differences_triangle(data)
exp = tri.map { |t| extrapolate(t) }

predictions = exp.map { |e| e[0][-1] }
sum = predictions.sum
puts sum
