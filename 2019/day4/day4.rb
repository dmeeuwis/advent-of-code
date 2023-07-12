lo, hi = 235741, 706948
digits = 6

def find_numbers(lb, ub, digits)
  all_numbers = (1..9).to_a.repeated_combination(digits)
  in_range = all_numbers.select {|d| (d.join('').to_i) > lb && (d.join('').to_i) < ub}
  has_repeats = in_range.select {|e| e.uniq.length != e.length}
  has_repeats.length
end

count = find_numbers(lo, hi, digits)
puts "P1: Number of possible passwords: #{count}"


def find_numbers_p2(lb, ub, digits)
  all_numbers = (1..9).to_a.repeated_combination(digits)
  in_range = all_numbers.select {|d| (d.join('').to_i) > lb && (d.join('').to_i) < ub}
  has_repeats = in_range.select {|e| e.uniq.length != e.length}
  no_decreasing = has_repeats.select { |r| r.join('') == r.sort().join('') }
  no_decreasing.length
end

count_p2 = find_numbers_p2(lo, hi, digits)
puts "P2: Number of possible passwords: #{count_p2}"
