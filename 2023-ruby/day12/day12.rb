require 'byebug'
require 'set'

f = File.open(ARGV[0])
lines = f.readlines.map do |l| 
  parts = l.split(" ") 
  nums = parts[1].split(',').map &:to_i
  [parts[0], nums]
end

#puts lines.inspect


# for each spring

# generate every possible combination
def generate(i)
  if i.size == 1
    if i[0] == '?'
      return ['#', '.']
    else
      return [i[0]]
    end
  end

  if i[0] == '?'
    subs = generate(i[1..])
    one = subs.map{ |x| '#' + x }
    two = subs.map{ |x| '.' + x }
    return one + two
  else
    subs = generate(i[1..])
    return subs.map { |x| i[0] + x }
  end
end


# check every one against then check at end of line, throw away bads
def throw_away(combos, check)
  regex = '^\.*' + check.map { |m| "#" * m }.join('\.+') + '\.*$'
  r = Regexp.new(regex)
  puts "Regex: #{regex} for check #{check}"
  combos.filter do |c|
    m = r.match? c
    #puts "Match #{c}? #{m}"
    m
  end
end

sum = 0
lines.each do |input|
  puts "Input #{input}"

  all =  generate(input[0])
  puts "Found #{all.size} strings."

  matching = throw_away(all, input[1])
  puts "Only #{matching.size} matched."
  sum += matching.size

  puts matching.inspect

  puts
end

puts
puts "Total: #{sum}"
