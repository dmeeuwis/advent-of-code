require 'byebug'

lines = File.read(ARGV[0]).split("\n")
pos = 50

def lock_abs(val)
  if val < 0
    (100 - val.abs) % 100
  else
    val % 100
  end
end

def clicks(pos, times, clicks = 0)
# puts "clicks #{pos}, #{times}"
  if times == 0
    [pos, clicks]
  else 
    if times < 0
      pos -= 1

      puts "Left #{pos}"

      if pos % 100 == 0
        clicks += 1
        puts "Click!"
      end
      
      clicks(lock_abs(pos), times + 1, clicks)
    else
      pos += 1

      puts "Right #{pos}"

      if pos % 100 == 0
        clicks += 1
        puts "Click!"
      end

      clicks(lock_abs(pos), times - 1, clicks) 
    end
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
    pos, count_clicks = clicks(pos, times)
  else 
    pos, count_clicks = clicks(pos, -1 * times)
  end

  puts "\tAfter pos at #{pos}, count_clicks #{count_clicks}"

  count += count_clicks
end

puts "Clicks: #{count}"
