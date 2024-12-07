require 'byebug'

$operators = ['*', '+', '||'].freeze
lines = File.readlines ARGV[0]

tests = lines.map do |line|
  r = {}
  m = line.match(/(\d*): (.*)/)
  {
    test_value: m[1].to_i,
     equation: m[2].split(' ').map(&:to_i)
  }
end

def build_str(equation, eqn = '', col = [])
  val = equation.shift
  eqn += val.to_s
  eqn += ' '

  if equation.empty?
    col.push eqn
    return
  end

  $operators.each do |op|
    build_str(equation.dup, eqn + op + ' ', col)
  end
end

def eval_eqn(equation)
  parts = equation.split(' ')
  value = 0
  operand1 = parts.shift
  while !parts.empty?
    operator = parts.shift
    operand2 = parts.shift

    if operator == '+'
      operand1 = (operand1.to_i + operand2.to_i).to_s
    elsif operator == '*'
      operand1 = (operand1.to_i * operand2.to_i).to_s
    elsif operator == '||'
      operand1 = "#{operand1}#{operand2}"
    end
  end
  operand1.to_i
end

passing_tests = Set.new
tests.each do |test|
  puts test
  col = []
  build_str(test[:equation], '', col)
  col.each do |c|
    puts "\t#{c}"
    res = eval_eqn(c)
    if test[:test_value] == res
      puts "\t\tFound match: #{c} = #{res}"
      passing_tests.add test[:test_value]
    end
  end
end

puts "Count is #{passing_tests.to_a.sum}"