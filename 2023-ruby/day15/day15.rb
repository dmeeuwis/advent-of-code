require 'byebug'

f = File.open(ARGV[0])
line = f.readlines.map { |l| l.chomp }[0]
instructions = line.split(',')
#puts instructions.inspect

def hsh(s)
  h = 0
  s.each_byte do |c|
    #print c
    h += c
    #print " => " 
    #print h
    h *= 17
    #print " => "
    #print h
    h = h % 256
    #print " => " 
    #print h
    #puts
  end
  h
end

def pb boxes
  boxes.each_with_index do |b,i|
    if b.size > 0
      puts "Box #{i}: #{b.map { |bi| "[#{bi}]" }.join " "}"
    end
  end
  nil
end

sum = 0
instructions.each do |part|
  h = hsh part
  sum += h
  #puts "#{h} => #{h}, sum => #{sum}"
end

puts "Part 1: #{sum}"

boxes = []
256.times { |i| boxes[i] = [] }

lens_locations = {}

instructions.each do |instruction|
  if instruction['=']
    parts = instruction.split '='
    label, focal_length = parts
    box_i = hsh label

    b = boxes[box_i]
    replaced = false
    b.each do |lens|
      if lens[0] == label
        puts "#{box_i} Replacing lens #{lens} with focal length #{focal_length}"
        lens[1] = focal_length
        replaced = true
        break
      end
    end

    if !replaced
      lens = [label, focal_length]
      b.push lens
      puts "#{box_i} Inserted lens #{label}"
    end

  else
    parts = instruction.split '-'
    label = parts[0]
    box_i = hsh label

    b = boxes[box_i]
    rejects = b.reject! { |lens| lens[0] == label }
    if rejects
      puts "#{box_i} Removed lens #{rejects} from the box."
    end
  end

  puts "After #{instruction}:"
  pb boxes
  puts
end

sum = 0

boxes.each_with_index do |box, i|
  box_num = i + 1
  box.each_with_index do |lens, lens_i|
    focal_length = lens[1].to_i
    power = box_num * (lens_i+1) * focal_length
    puts "Box #{i} lens #{lens} has power #{power}"
    sum += power
  end
end

puts "P2: power is #{sum}"
