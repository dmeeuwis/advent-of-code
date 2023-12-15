require 'byebug'
require 'set'

f = File.open(ARGV[0])
line = f.readlines.map { |l| l.chomp }[0]
parts = line.split(',')
puts parts.inspect

def hash(s)
  hash = 0
  s.each_byte do |c|
    print c
    hash += c
    print " => " 
    print hash
    hash *= 17
    print " => "
    print hash
    hash = hash % 256
    print " => " 
    print hash
    puts
  end
  hash
end

sum = 0
parts.each do |part|
  h = hash part
  sum += h
  puts "#{h} => #{h}, sum => #{sum}"
end

puts sum
