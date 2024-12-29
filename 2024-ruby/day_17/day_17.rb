require 'byebug'
lines = File.readlines ARGV[0]

registers = Hash.new
registers[:a] = lines[0].split(' ')[2].to_i
registers[:b] = lines[1].split(' ')[2].to_i
registers[:c] = lines[2].split(' ')[2].to_i

ip = 0

program = lines[-1].split(' ')[1]
ops = program.split(',').map(&:to_i)

puts "Registers: #{registers}"

def truncate(num)
  num & 0xFFF
end

def combo_operand(registers, op)
  case op
  when 0..3
    return op
  when 4
    return registers[:a]
  when 5
    return registers[:b]
  when 6
    return registers[:c]
  when 7
    raise "Invalid operand"
  end
end

outs = []

while ip < ops.size

  puts registers

  op = ops[ip]
  literal_operand = ops[ip + 1]

  puts "#{op} #{literal_operand}"

  case op
  when 0 # adv
    num = registers[:a]
    operand = combo_operand registers, literal_operand
    full = num / (2 ** operand)
    registers[:a] = full

  when 1 # bxl
    registers[:b] = registers[:b] ^ literal_operand

  when 2 # bst
    registers[:b] = combo_operand(registers, literal_operand) % 8

  when 3 # jnz
    if registers[:a] != 0
      ip = literal_operand
      next
    end

  when 4 # bxc
    registers[:b] = registers[:b] ^ registers[:c]

  when 5 # out
    operand = (combo_operand registers, literal_operand) % 8
    puts "Output: #{operand}"
    puts registers
    outs.push operand

  when 6 # bdv
    num = registers[:a]
    operand = combo_operand registers, literal_operand
    registers[:b] = num / (2 ** operand)

  when 7 # cdv
    num = registers[:a]
    operand = combo_operand registers, literal_operand
    registers[:c] = num / (2 ** operand)

  end

  ip += 2
end

puts registers
puts outs.join(',')