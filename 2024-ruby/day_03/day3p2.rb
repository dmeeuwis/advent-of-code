require 'byebug'
lines = File.readlines ARGV[0]

sum = 0
ignore = false
lines.each do |line|
  line.scan(/(mul\(\d{1,4},\d{1,4}\))|(don't\(\))|(do\(\))/).each do |m|
    if m[2] == 'do()'
      ignore = false
    elsif m[1] == "don't()"
      ignore = true
    elsif m[0].start_with? 'mul'
      next if ignore
      r = m[0].match(/mul\((\d{1,4}),(\d{1,4})\)/)
      res = r[1].to_i * r[2].to_i
      sum += res
    end
  end
end

puts "Sum is #{sum}"