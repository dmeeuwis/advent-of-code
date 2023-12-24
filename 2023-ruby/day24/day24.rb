require 'set'
require 'byebug'

POS = 0
VEL = 1
#RANGE = [7, 27]
RANGE = [200000000000000, 400000000000000]

f = File.open(ARGV[0])
hail = f.readlines.map do |l|
  match = l =~ /(\-?\d+),\s+(\-?\d+),\s+(\-?\d+)\s+@\s+([-]?\d+),\s+([-]?\d+),\s+([-]?\d+)/
  px, py, pz, vx, vy, vz = $1.to_f, $2.to_f, $3.to_f, $4.to_f, $5.to_f, $6.to_f
  [ [px,py,pz], [vx,vy,vz] ]
end

#position(t1) = pos1 + t * vel2
#position(t2) = pos1 + t * vel2


def line_intersection(line1, line2)
  xdiff = [line1[0][0] - line1[1][0], line2[0][0] - line2[1][0]]
  ydiff = [line1[0][1] - line1[1][1], line2[0][1] - line2[1][1]]

  def det(a, b)
    a[0] * b[1] - a[1] * b[0]
  end

  div = det(xdiff, ydiff)
  if div == 0
     return nil # no intersect
  end

  d = [det(*line1), det(*line2)]
  x = det(d, xdiff) / div
  y = det(d, ydiff) / div
  return [x, y]
end


def count_intersects(hail)
  count = 0
  seen = Set.new
  hail.each_with_index do |h1, h1_i|
    hail.each_with_index do |h2, h2_i|
      next if seen.include?(Set.new [h1_i, h2_i])
      seen.add Set.new [h1_i, h2_i]

      next if h1_i == h2_i

      h1p1 = [ h1[0][0], h1[0][1] ]
      h1p2 = [ h1[0][0] + h1[1][0], h1[0][1] + h1[1][1] ]
      line1 = [ h1p1, h1p2 ]

      h2p1 = [ h2[0][0], h2[0][1] ]
      h2p2 = [ h2[0][0] + h2[1][0], h2[0][1] + h2[1][1] ]
      line2 = [ h2p1, h2p2 ]

      intersect = line_intersection line1, line2

      puts "Hailstone #{h1_i}: #{h1} #{line1}"
      puts "Hailstone #{h2_i}: #{h2} #{line2}"
      puts "Paths will cross at #{intersect}"

      next if intersect.nil?

      if  intersect[0] >= RANGE[0] && intersect[0] <= RANGE[1] &&
          intersect[1] >= RANGE[0] && intersect[1] <= RANGE[1]

        # test if before t0 for line1
        if 
           (intersect[0] < h1[POS][0] && h1[VEL][0] >= 0) ||  # h1 before on x when going pso
           (intersect[0] < h2[POS][0] && h2[VEL][0] >= 0) ||  # h2 before on x when going pos
           (intersect[1] < h1[POS][1] && h1[VEL][1] >= 0) ||  # h2 before on y when going pos
           (intersect[1] < h2[POS][1] && h2[VEL][1] >= 0) ||  # h2 before on y when going pos

           (intersect[0] > h1[POS][0] && h1[VEL][0] <= 0) ||  # h1 after on x when going neg
           (intersect[0] > h2[POS][0] && h2[VEL][0] <= 0) ||  # h2 after on x when going neg
           (intersect[1] > h1[POS][1] && h1[VEL][1] <= 0) ||  # h2 after on y when going neg
           (intersect[1] > h2[POS][1] && h2[VEL][1] <= 0) ||  # h2 after on y when going neg
           false

          puts "Hailstone's paths crossed in the past."
          
        else 
          count += 1
          puts "Found range INSIDE area"
        end

      else 
        puts "Found range OUTSIDE area"
      end
      puts
    end
  end
  count
end

count = count_intersects(hail)
puts "Count is #{count}"
