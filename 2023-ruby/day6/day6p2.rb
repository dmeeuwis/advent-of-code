require 'set'
require 'byebug'

f = File.open(ARGV[0])
lines = f.readlines.map { |l| l.chomp }

lines[0] =~ /Time:\s+(\d+)/
times = [$1.to_i]
lines[1] =~ /Distance:\s+(\d+)/
distances = [$1.to_i]

puts times
puts distances

races = times.size
all_race_winners = []
(0..races-1).each do |race_index|
  puts "Race #{race_index} times #{times[race_index]} distance #{distances[race_index]}"
  all_race_winners.push []

  time = times[race_index]
  puts time
  (0..time).each do |time_trial|

    puts "time_trial #{time_trial}"
    time_left = times[race_index] - time_trial
    speed = time_trial
    distance = time_left * speed

    puts "Race #{race_index} time trial #{time_trial} found distance #{distance}"
    if distance > distances[race_index]
      all_race_winners[race_index].push [time_trial, distance]
      puts "Winner!"
    end
  end

  puts "Found winners for race #{race_index}: #{all_race_winners[race_index]}"
end

sum = 1
all_race_winners.each do |w|
  sum = sum * w.size
end

puts sum
