require 'byebug'

line = File.readlines(ARGV[0]).first

data = line.chars.to_a.each_with_index.map do |c, i|
  if i % 2 == 0
    id = (i.to_i) / 2
    id.to_s * c.to_i
  else
    '.' * c.to_i
  end
end.join.split('')

def compact(data)
  while true
    # find first free space
    start = data.index('.')

    # find last occupied space
    finish = data.rindex do |c|
      c != '.'
    end

    return data if finish < start

    # swap them
    data[start], data[finish] = data[finish], data[start]

    #puts data.join
  end
end

puts "Start:\n#{data.join}"
finish = compact(data)
puts "Finish:\n#{finish.join}"

def checksum(data)
  sum = 0
  data.each_with_index do |c, i|
    next if c == '.'
    sum += c.to_i * i
    puts "Sum: #{c} * #{i} #{c.to_i * i}...#{sum}"
  end
  sum
end

puts "Checksum: #{checksum(finish)}"
byebug
puts "Done"