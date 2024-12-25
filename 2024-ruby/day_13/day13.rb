require 'byebug'

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

machines_blocks = data.split("\n\n")
machines = machines_blocks.map do |block|
  lines = block.split("\n")
  a_button = read_button lines[0]
  b_button = read_button lines[1]
  prize = read_button lines[2], true
  { a: a_button, b: b_button, prize: prize }
end

def check_all(machine)
  a = (0..100).to_a
  b = (0..100).to_a

  all_combos = a.product b

  all_combos.each do |combo|
    x = machine[:a][0] * combo[0]
    y = machine[:a][1] * combo[0]

    x += machine[:b][0] * combo[1]
    y += machine[:b][1] * combo[1]

    return combo if [x, y] == machine[:prize]
  end

  return nil
end

total = 0
machines.each do |machine|
  puts "Machine: #{machine}"
  res = check_all machine
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