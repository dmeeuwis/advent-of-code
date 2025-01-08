require 'byebug'
require 'graphviz'

input = File.read(ARGV[0])
parts = input.split("\n\n")

initial_value_lines = parts.first.split("\n")
values = Hash.new
initial_value_lines.each do |line|
  pieces = line.split(': ')
  values[pieces[0]] = pieces[1].strip.to_i
end

map = Hash.new { |h, k| h[k] = [] }
gate_lines = parts.last.split("\n")
gates = gate_lines.map do |line|
  pieces = line.split(' ')
  in1, op, in2, _, out = pieces
  map[in1].push [op, in2, out]
  map[in2].push [op, in1, out]
end

initial_keys = values.keys
while initial_keys.size > 0
  name = initial_keys.shift
  value = values[name]

  gates_connected = map[name]
  gates_connected.each do |gate|
    op, in2, out = gate

    if !values[in2]
      initial_keys.push in2
      next
    end
  
    case op
    when 'AND'
      values[out] = value & values[in2]
    when 'OR'
      values[out] =  value | values[in2]
    when 'XOR'
        values[out] = value ^ values[in2]
    else
      raise "Unknown operation: #{op}"
    end

    initial_keys.push out
  end
end

puts "Final state:"
puts "{"
values.keys.sort.each do |k|
  puts "#{k}: #{values[k]},"
end
puts "}"

output_keys = values.keys.select { |k| k.start_with? 'z' }.sort.reverse
puts "Output keys: #{output_keys}"
output_boolean = output_keys.map { |k| values[k] }.join('')
puts "Output value: #{output_boolean}"
output_value = output_boolean.to_i(2)
puts "Output value: #{output_value}"

def graph_part_two(gates)
    pairs = gates.values.flatten(1)
    ands = gates.values.flatten(1).filter { |gate| gate[0] == "AND" }.map { |gate| gate[1..2] }.join('; ')
    ors = gates.values.flatten(1).filter { |gate| gate[0] == "OR" }.map { |gate| gate[1..2] }.join('; ')
    xors = gates.values.flatten(1).filter { |gate| gate[0] == "XOR" }.map { |gate| gate[1..2] }.join('; ')

    graph = <<-GRAPH
        digraph G {
            subgraph {
               node [style=filled,color=green]
                 x00 -> x01 -> x02 -> x03 -> x04 -> x05 -> x06 -> x07;
            }
            subgraph {
                node [style=filled,color=gray]
                y00 -> y01 -> y02 -> y03 -> y04 -> y05 -> y06 -> y07;
            }
            subgraph {
                node [style=filled,color=gray]
                z00 -> z01 -> z02 -> z03 -> z04 -> z05 -> z06 -> z07;
            }
            subgraph {
                node [style=filled,color=pink]
                #{ ands };
            }
            subgraph {
                node [style=filled,color=yellow];
                #{ ors };
            }
            subgraph {
                node [style=filled,color=lightblue];
                #{ xors };
            }
    GRAPH

    puts graph
    gates.each do |out, values| 
        _, left, right, = values
        values.each do |value|
          puts("    #{value[1]} -> #{out}; #{value[2]} -> #{out};")
        end
    end
    puts("}")
end

graph_part_two(map)
