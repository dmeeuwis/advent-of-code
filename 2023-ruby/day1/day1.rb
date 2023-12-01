f = File.open(ARGV[0])

lineList = f.readlines.map(&:chomp)
puts lineList

sum = 0
lineList.map do |line|
  puts line
  nums = line.gsub(/[a-zA-Z]/, '')
  puts nums
  first = nums[0]
  last = nums[-1]
  calibration = (first + "" + last).to_i

  puts "Calibration: #{calibration}"
  calibration
  sum += calibration
end

puts sum