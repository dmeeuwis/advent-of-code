require 'byebug'

f = File.open(ARGV[0])

lineList = f.readlines.map(&:chomp)
BIG = 9999999

nums = [ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" ]

sum = 0
newList = lineList.map do |line|
  puts line

  earliest  = nil
  earliest_index = BIG
  nums.each do |num|
    index = line.index(num)
    puts "...#{num} #{line.index(num)}"

    earliest_digit = BIG
    ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].each do |digit|
      digit_index = line.index(digit)
      if !digit_index.nil? && digit_index < earliest_digit
        earliest_digit = digit_index
      end
    end

    if !index.nil? && index < earliest_index && index < earliest_digit
      earliest = num
      earliest_index = index
      puts "Matched! #{earliest} #{earliest_index}"
    end
  end
  if earliest_index != BIG
    line = line.sub(earliest, (nums.index(earliest)+1).to_s)
  end
  puts "=> " + line

  last = nil
  last_index = BIG
  nums.each do |num|
    index = line.reverse.index(num.reverse)
    puts "...#{num} #{line.index(num)}"
    if !index.nil? && index < last_index
      last = num
      last_index = index
      puts "Matched: #{num} #{last_index}"
    end
  end
  puts "Matched: #{last} #{line.length - last_index}"

  if last_index != BIG
    #last_index = line.length - last_index - num.length
    #line = line.sub(last, (nums.index(last)+1).to_s)
    line = line.reverse.sub(last.reverse, (nums.index(last)+1).to_s).reverse
  end
  puts "=> " + line
  line

  numLine = line.gsub(/[a-zA-Z]/, '')
  puts "Nums: #{numLine}"
  first = numLine[0]
  last = numLine[-1]
  calibration = (first + "" + last).to_i

  puts calibration
  calibration
  sum += calibration
end

puts sum