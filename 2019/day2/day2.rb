f = File.open(ARGV.first)
lineList = f.readlines

state = lineList[0].split(",").map { |n| n.to_i }
#puts "Initial state: #{state}"

def calculate(program)
  pc = 0
  while true
    op = program[pc]
    #puts "Loop: #{pc} #{op} #{program}"
    if op == 1
      program[program[pc+3]] = program[program[pc+1]] + program[program[pc+2]]
      pc += 4
    elsif op == 2
      program[program[pc+3]] = program[program[pc+1]] * program[program[pc+2]]
      pc += 4
    elsif op == 99
      return program
    end
  end
end

state[1] = 12
state[2] = 2
end_state = calculate(state)
puts("Part 1 End state: #{end_state[0]}")

def attempt(program, attempt)
  program[1] = attempt[0]
  program[2] = attempt[1]

  out_state = calculate(program)
  if out_state[0] == 19690720
      return attempt
  end

  false
end

attempts = (0..100).to_a.product (0..100).to_a
for a in attempts do
    state = lineList[0].split(",").map { |n| n.to_i }
    if attempt(state, a)
        puts "Part 2: found it! #{a} #{(100*a[0] + a[1])}"
        exit 0
    end
end

puts("Part 2: failure, no match found!")
