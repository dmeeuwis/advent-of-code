require 'byebug'
require 'z3'

# read file as a big string
data = File.read ARGV[0]

def read_button(line, prize=false)
  parts = line.split(": ")
  parts_2 = parts[1].split(", ")

  if prize
    x = parts_2[0][2..].to_i
    y = parts_2[1][2..].to_i
  else 
    x = parts_2[0][1..].to_i
    y = parts_2[1][1..].to_i
  end

  [x,y]
end

#ef solve_z3(ax, ay, bx, by, px, py)
def solve_z3(machine)
  ax = machine[:a][0]
  ay = machine[:a][1]
  bx = machine[:b][0]
  by = machine[:b][1]
  px = machine[:prize][0]
  py = machine[:prize][1]

  solver = Z3::Solver.new

  a = Z3.Int('a')
  b = Z3.Int('b')

  solver.assert(a >= 0)
  solver.assert(b >= 0)
  solver.assert(ax * a + bx * b == px)
  solver.assert(ay * a + by * b == py)

  return nil unless solver.satisfiable?

  [solver.model[a].to_i, solver.model[b].to_i]
end

machines_blocks = data.split("\n\n")
machines = machines_blocks.map do |block|
  lines = block.split("\n")
  a_button = read_button lines[0]
  b_button = read_button lines[1]
  prize = read_button lines[2], true
  { a: a_button, b: b_button, prize: prize }
end

total = 0
machines.each do |machine|
  puts "Machine: #{machine}"
  res = solve_z3 machine
  puts "Result: #{res}"
  if res
    cost = res[0] * 3 + res[1]
    total += cost
    puts "Cost: #{cost}"
  else 
    puts "No solution"
  end
end

puts "Total cost: #{total}"