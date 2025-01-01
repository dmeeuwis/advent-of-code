data = File.readlines(ARGV[0]).map { |line| line.strip.split(',').map(&:to_i) }

def search(i, data)
  seen = Set.new data[0...i]
  todo = [[0, [0,0]]]

  todo.each do |dist_info|
    dist = dist_info[0]
    x, y = dist_info[1]

    return dist if [x,y] == [70,70]

    [[x,y+1], [x,y-1], [x+1,y], [x-1,y]].each do |x,y|
      if !seen.include?([x,y]) && 0 <= x && x <= 70 && 0 <= y && y <= 70
        todo.push([dist+1, [x,y]])
        seen.add([x,y])
      end
    end
  end

  return nil
end

i = 1024
while true
  res = search(i, data)
  unless res
    puts data[i-1].inspect
    exit 0
  end
  i += 1
end