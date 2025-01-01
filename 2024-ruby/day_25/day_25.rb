require 'byebug'

file = File.read ARGV[0]
segments = file.split("\n\n")

keys = []
locks = []

segments.each do |segment|
  lines = segment.split("\n")
  if lines.first == '#####' && lines.last == '.....'
    locks << lines[1..-2]
  else
    keys << lines[1..-2]
  end
end

def transpose(lines)
  longest = lines.map { |l| l.length }.max

  (0..longest).map do |index|
    lines.map { |l| l[index] || ' ' }.join
  end
end

def count_cols(char, segment)
  easier = transpose(segment)
  easier.map { |line| line.count(char) }
end

key_counts = keys.map { |key| count_cols('#', key) }
puts "Keys: #{key_counts}"
lock_counts = locks.map { |lock| count_cols('#', lock) }
puts "Locks: #{lock_counts}"

def compare(key, lock)
  5.times do |i|
    if key[i] + lock[i] > 5
      puts "Key: #{key}"
      puts "Lock: #{lock}"
      puts "Failed"
      return false
    end
  end

  true
end

all_pairings = key_counts.product(lock_counts)
success = 0
all_pairings.each do |pairing|
  key, lock = pairing
  if compare(key, lock)
    success += 1
  end
end

puts "Found #{success} successful pairings"