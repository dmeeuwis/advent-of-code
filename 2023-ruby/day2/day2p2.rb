f = File.open(ARGV[0])
lines = f.readlines

sum = 0
lines.each do |line|
  game, rounds = line.split(": ")
  sessions = rounds.split("; ")

  max_red = 0
  max_green = 0
  max_blue = 0

  sessions.each do |session|
    session.split(", ").each do |round|
      colors = round.split " "
      if colors[1] == 'green'
        max_green = colors[0].to_i if colors[0].to_i > max_green
      elsif colors[1] == 'blue'
        max_blue = colors[0].to_i if colors[0].to_i > max_blue
      elsif colors[1] == 'red'
        max_red = colors[0].to_i if colors[0].to_i > max_red
      end
    end
  end

  power = max_red * max_blue * max_green
  puts "Power = #{max_red} * #{max_blue} * #{max_red} = #{power}"
  sum += power
end

puts "Sum of powers is #{sum}"