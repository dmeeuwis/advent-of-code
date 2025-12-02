require 'byebug'

lines = File.read(ARGV[0]).split("\n")
pos = 50

def lock_abs(val)
  puts "lock_abs(#{val})"
  if val < 0
    (100 - val.abs) % 100
  else
    val % 100
  end
end

puts lines
moves = lines.map do |line|
  move, *number = line.chars
  [move, number.join('').to_i]
end

count = 0
moves.each do |move|
  direction = move[0]
  times = move[1]
  puts "Turning #{direction} #{times}"
  if direction == 'R'
    pos = lock_abs(pos + times)
  else 
    pos = lock_abs(pos - times)
  end

  puts "\tAfter pos at #{pos}"

  if pos == 0
    count += 1
    puts "\tScore!"
  end
end

puts "Times at zero: #{count}"
