
points = [65 + 131 * 0, 65 + 131 * 1, 65 + 131 * 2]
plots_by_steps = { 65 => 3682, 196 => 32768, 327 => 90820 }
one = plots_by_steps[65]
two = plots_by_steps[196]
three = plots_by_steps[327]

puts "#{one} #{two} #{three}"

a = (three - (two * 2) + one) / 2
b = two - one - a
c = one
n = (26_501_365 - 65) / 131

soln = (a * (n**2)) + (b*n) + c
puts "Soln is #{soln}"

def try
  a = (y[2] - (2 * y[1]) + y[0]) / 2
  b = y[1] - y[0] - a
  c = y[0]
  return (a * n**2) + (b * n) + c
end
