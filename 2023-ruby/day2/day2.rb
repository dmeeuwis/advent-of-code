f = File.open(ARGV[0])
lines = f.readlines

max_red = 12
max_green = 13
max_blue = 14

sum = 0

lines.each do |line|
  game, rounds = line.split(": ")
  
  sessions = rounds.split("; ")
  fail = false
  sessions.each do |session|
    red, blue, green = 0, 0, 0
    session.split(", ").each do |round|
      colors = round.split " "
      if colors[1] == 'green'
        fail = true if colors[0].to_i > max_green
      elsif colors[1] == 'blue'
        fail = true if colors[0].to_i > max_blue
      elsif colors[1] == 'red'
        fail = true if colors[0].to_i > max_red
      end
    end
  end

  if !fail
    puts "Session #{game} is OK!"
    r = game.match /Game (\d+)/
    id = r.captures[0]
    sum += id.to_i
  else 
    puts "Session #{game} failed!"
  end
end
puts "Sum is #{sum}"