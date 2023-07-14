f = File.open(ARGV.first)
lineList = f.readlines

state = lineList[0].split(",").map { |n| n.to_i }
puts "Initial state: #{state}"

OPS = { 1 => "+", 2 => "*", 3 => "I", 4 => "O", 99 => "X" }

def calculate(p, input, output)
  position =  lambda { |p, pc, inc| puts "position #{pc+inc} => #{p[p[pc+inc]]}"; p[p[pc+inc]] }
  immediate = lambda { |p, pc, inc| puts "immediate #{pc+inc} => #{p[pc+inc]}"; p[pc+inc] }

  pc = 0
  while true
    chars = p[pc].to_s.chars
    op = chars.pop(2).join.to_i
    param = chars.reverse.join

    param_1_toggle = param.size >= 1 && param[0] && param[0] != "0"
    param_1_mode = param_1_toggle ? immediate : position
    param_2_toggle = param.size >= 2 && param[1] && param[1] != "0"
    param_2_mode = param_2_toggle ? immediate : position
    param_3_toggle = param.size >= 3 && param[2] && param[2] != "0"
    param_3_mode = param_3_toggle ? immediate : position

    puts "Loop: op=#{op} #{OPS[op]} param=#{param} pc=#{pc} #{param_1_toggle} #{param_2_toggle} #{param_3_toggle} "
#   puts "State: #{p}"

    if op == 1 # addition
      p[p[pc+3]] = param_1_mode.(p, pc, 1) + param_2_mode.(p, pc, 2)
      puts "#{pc+3} => #{param_1_mode.(p, pc, 1)} + #{param_2_mode.(p, pc, 2)}"
      pc += 4
    elsif op == 2 # multiplication
      p[p[pc+3]] = param_1_mode.(p, pc, 1) * param_2_mode.(p, pc, 2)
      puts "#{pc+3} => #{param_1_mode.(p, pc, 1)} * #{param_2_mode.(p, pc, 2)}"
      pc += 4
    elsif op == 3 # input
      p[p[pc+1]] = input.pop
      puts "IN #{p[p[pc+1]]} => #{pc+1}"
      pc += 2
    elsif op == 4 # output
      output << p[p[pc+1]] # param_1_mode.(p, pc, 1) #p[pc+1]]
      puts "OUT #{p[p[pc+1]]}" ##{param_1_mode.(p, pc, 1)}"
      pc += 2
    elsif op == 99 # exit
      puts "END"
      return p
    else 
      raise "Unknown OP: #{op}"
    end
  end
end

input = [1]
output = []
end_state = calculate(state, input, output)
puts("Part 1: #{output}")
