require 'set'

points = File.read(ARGV[0]).split("\n").map { |l| l.split(",").map(&:to_i) }

def inside_polygon?(point, polygon)
  x, y = point
  inside = false
  j = polygon.length - 1

  polygon.each_with_index do |(xi, yi), i|
    xj, yj = polygon[j]
    if ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi).to_f / (yj - yi) + xi)
      inside = !inside
    end
    j = i
  end

  inside
end

def on_edge?(point, polygon)
  x, y = point
  polygon.each_with_index do |(x1, y1), i|
    x2, y2 = polygon[(i + 1) % polygon.length]
    return true if x1 == x2 && x == x1 && y.between?([y1, y2].min, [y1, y2].max)
    return true if y1 == y2 && y == y1 && x.between?([x1, x2].min, [x1, x2].max)
  end
  false
end

def valid_rectangle?(x1, y1, x2, y2, polygon, red_set)
  rx1, rx2 = [x1, x2].minmax
  ry1, ry2 = [y1, y2].minmax

  [[rx1, ry1], [rx2, ry1], [rx1, ry2], [rx2, ry2]].each do |corner|
    next if red_set.include?(corner) || on_edge?(corner, polygon) || inside_polygon?(corner, polygon)
    return false
  end

  polygon.each_with_index do |(px1, py1), i|
    px2, py2 = polygon[(i + 1) % polygon.length]

    if px1 == px2 && px1 > rx1 && px1 < rx2
      ymin, ymax = [py1, py2].minmax
      return false if ymin < ry2 && ymax > ry1
    end

    if py1 == py2 && py1 > ry1 && py1 < ry2
      xmin, xmax = [px1, px2].minmax
      return false if xmin < rx2 && xmax > rx1
    end
  end

  true
end

red_set = Set.new(points)
max_area = 0

points.combination(2) do |(x1, y1), (x2, y2)|
  area = ((x2 - x1).abs + 1) * ((y2 - y1).abs + 1)
  next if area <= max_area
  max_area = area if valid_rectangle?(x1, y1, x2, y2, points, red_set)
end

puts "Maximum area: #{max_area}"
