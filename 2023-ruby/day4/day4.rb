require 'set'
require 'byebug'

f = File.open(ARGV[0])
lines = f.readlines

sum = 0
lines.each do |line|
  line =~ /Card\s+(\d+): ([^|]*)\|(.*)/
  game_id = $1
  winning = $2.strip.split(" ").map { |c| c.to_i }
  mine = $3.strip.split(" ").map { |c| c.to_i }
  my_winning = winning.intersection mine
  points = (2 ** (my_winning.size-1)).to_i
  puts "Game #{game_id} wins #{my_winning} so #{points} points!"
  sum += points
end
puts "Sum: #{sum}"
