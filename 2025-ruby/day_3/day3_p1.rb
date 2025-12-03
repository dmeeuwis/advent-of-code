
banks = File.read(ARGV[0]).split("\n")

def find_best(bank)
  best_val = -1
  bank.chars.each_with_index do |first, i|
    bank.chars.each_with_index do |second, j|
      next if i == j
      next if j < i

      num = "#{first}#{second}".to_i
      if num > best_val 
        best_val = num
      end
    end
  end
  best_val
end

sum = 0
banks.map do |bank|
  best = find_best bank
  puts "Best for #{bank} is #{best}"
  sum += best
end

puts "Best Sum is #{sum}"
