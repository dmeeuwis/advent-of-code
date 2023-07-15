f = File.open(ARGV.first)
lineList = f.readlines

state = lineList[0].split(",").map { |n| n.to_i }
puts "Initial state: #{state}"

def calculate(p, input, output)
  #position =  lambda { |p, pc, inc| puts "position #{pc+inc} => #{p[p[pc+inc]]}"; p[p[pc+inc]] }
  #immediate = lambda { |p, pc, inc| puts "immediate #{pc+inc} => #{p[pc+inc]}"; p[pc+inc] }
  position =  lambda { |p, pc, inc| p[p[pc+inc]] }
  immediate = lambda { |p, pc, inc| p[pc+inc] }

  pc = 0
  while true
    chars_orig = p[pc].to_s.chars
    chars = p[pc].to_s.chars
    op = chars.pop(2).join.to_i
    param = chars.reverse.join

    param_1_toggle = param.size >= 1 && param[0] && param[0] != "0"
    param_1_mode = param_1_toggle ? immediate : position
    param_2_toggle = param.size >= 2 && param[1] && param[1] != "0"
    param_2_mode = param_2_toggle ? immediate : position
    param_3_toggle = param.size >= 3 && param[2] && param[2] != "0"
    param_3_mode = param_3_toggle ? immediate : position

#   puts "Loop: chars=#{chars_orig.join} op=#{op} param=#{param} pc=#{pc} #{param_1_toggle} #{param_2_toggle} #{param_3_toggle} "

    if op == 1 # addition
      p[p[pc+3]] = param_1_mode.(p, pc, 1) + param_2_mode.(p, pc, 2)
#     puts "#{pc+3} => #{param_1_mode.(p, pc, 1)} + #{param_2_mode.(p, pc, 2)}"
      pc += 4
    elsif op == 2 # multiplication
      p[p[pc+3]] = param_1_mode.(p, pc, 1) * param_2_mode.(p, pc, 2)
#     puts "#{pc+3} => #{param_1_mode.(p, pc, 1)} * #{param_2_mode.(p, pc, 2)}"
      pc += 4
    elsif op == 3 # input
      p[p[pc+1]] = input.pop
#     puts "IN #{p[p[pc+1]]} => #{pc+1}"
      pc += 2
    elsif op == 4 # output
      output << p[p[pc+1]]
#     puts "OUT #{p[p[pc+1]]}"
      pc += 2
    elsif op == 5 # jump-if-true
      if param_1_mode.(p, pc, 1) != 0
#       puts "JUMP_IF_TRUE #{param_1_mode.(p, pc, 1)}"
        pc = param_2_mode.(p, pc, 2)
      else
#       puts "NO_JUMP_IF_TRUE #{param_2_mode.(p, pc, 1)}"
        pc += 3
      end
    elsif op == 6 # jump-if-false
      if param_1_mode.(p, pc, 1) == 0
#       puts "JUMP_IF_FALSE #{param_1_mode.(p, pc, 1)}"
        pc = param_2_mode.(p, pc, 2)
      else
#       puts "NO_JUMP_IF_FALSE #{param_2_mode.(p, pc, 1)}"
        pc += 3
      end
    elsif op == 7 # lt
      if param_1_mode.(p, pc, 1) < param_2_mode.(p, pc, 2)
#       puts "LT TRUE #{pc+2} => 1    #{param_1_mode.(p, pc, 1)} < #{param_2_mode.(p, pc, 2)}"
        p[p[pc+3]] = 1
      else 
#       puts "LT FALSE #{pc+2} => 0   #{param_1_mode.(p, pc, 1)} < #{param_2_mode.(p, pc, 2)}"
        p[p[pc+3]] = 0
      end
      pc += 4
    elsif op == 8 # eq
      if param_1_mode.(p, pc, 1) == param_2_mode.(p, pc, 2)
#       puts "EQ TRUE #{pc+2} => 1"
        p[p[pc+3]] = 1
      else 
#       puts "LT FALSE #{pc+2} => 0"
        p[p[pc+3]] = 0
      end
      pc += 4
    elsif op == 99 # exit
#     puts "END"
      return p
    else 
      raise "Unknown OP: #{op}"
    end
  end
end

combinations = [0,1,2,3,4].repeated_permutation(5).to_a
max, phase, best = -1, nil, nil
combinations.each do |c|
  puts "Looking at Combo #{c}"
  prev = 0
  for phase in c
    input = [phase, prev]
    output = []
    
    print "\t#{phase}: in=#{input} "
    end_state = calculate(state, input, output)
    prev = output.pop
    puts " => #{prev}"
  end

  puts "\t#{c} output: #{prev}"

  if prev > max
    puts "Best Yet!\n\n"
    max = prev
    best = c
  end

end

puts "Part 1: Found best #{best} with power #{max}"
