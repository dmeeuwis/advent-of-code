require 'byebug'
lines = File.readlines ARGV[0]

sum = 0
lines.each do |line|
  line.scan(/mul\((\d{1,4}),(\d{1,4})\)/).each do |m|
    res = m[0].to_i * m[1].to_i
    puts "mul(#{m[0]}, #{m[1]}) = #{res}"
    sum += res
  end
end

puts "Sum is #{sum}"