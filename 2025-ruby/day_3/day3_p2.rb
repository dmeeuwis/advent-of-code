banks = File.read(ARGV[0]).split("\n")
banks = banks.map { |bank| bank.chars.map(&:to_i) }

def array_to_int(arr)
  arr.reduce(0) { |acc, digit| acc * 10 + digit }
end

def find_best_(bank, k, pos = 0, current_num = 0, digits_picked = 0, best = [0])
  if digits_picked == k
    best[0] = current_num if current_num > best[0]
    return best[0]
  end

  remaining_needed = k - digits_picked
  remaining_available = bank.length - pos

  return best[0] if remaining_available < remaining_needed

  max_possible = current_num
  remaining_needed.times { max_possible = max_possible * 10 + 9 }

  return best[0] if max_possible <= best[0]

  (pos..bank.length - remaining_needed).each do |i|
    new_num = current_num * 10 + bank[i]
    find_best_recursive(bank, k, i + 1, new_num, digits_picked + 1, best)
  end

  best[0]
end

def find_best_brute_force(bank, k)
  find_best_recursive(bank, k)
end

sum = 0
banks.each_with_index do |bank, idx|
  puts "Bank: #{bank.join}"
  best = find_best_brute_force(bank, 12)
  puts "  Best: #{best}"
  sum += best
end

puts "Sum: #{sum}"
