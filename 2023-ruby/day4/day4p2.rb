require 'set'
require 'byebug'

f = File.open(ARGV[0])
lines = f.readlines

multipliers = Hash.new { |k,v| v = 1 }
points = Hash.new { |k,v| v = 0 }

lines.each do |line|
  line =~ /Card\s+(\d+): ([^|]*)\|(.*)/
  game_id = $1.to_i
  winning = $2.strip.split(" ").map { |c| c.to_i }
  mine = $3.strip.split(" ").map { |c| c.to_i }
  my_winning = winning.intersection mine
  (game_id+1..game_id+my_winning.size).each do |id|
    multipliers[id] += multipliers[game_id]
  end
  points[game_id] = (2 ** (my_winning.size-1)).to_i

  puts "Game #{game_id} wins #{my_winning}"
end

card_count = 0
points.keys.each do |game_id|
  p = multipliers[game_id]
  card_count += p
  puts "Game #{game_id} points=#{points[game_id]} * #{multipliers[game_id]} = #{p}"
end
puts "Sum: #{card_count}"
