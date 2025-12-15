require 'z3'

def parse_line(line)
  [line[/\[([^\]]+)\]/, 1], line.scan(/\(([^)]+)\)/).flatten, line[/\{([^}]+)\}/, 1]]
end

manual = File.read(ARGV[0]).split("\n").map { |line| parse_line(line) }

class Machine
  def initialize(manual_entry)
    goal_state, buttons, joltage = manual_entry
    @target = joltage.split(',').map(&:to_i)
    @buttons = buttons.map { |b| b.split(',').map(&:to_i) }
    @num_counters = @target.length
  end

  def find_shortest_presses
    solver = Z3::Optimize.new

    button_vars = @buttons.map.with_index { |_, i| Z3.Int("b#{i}") }
    button_vars.each { |v| solver.assert(v >= 0) }

    @num_counters.times do |counter_idx|
      terms = []
      @buttons.each_with_index do |button, btn_idx|
        if button.include?(counter_idx)
          terms << button_vars[btn_idx]
        end
      end
      sum = terms.empty? ? 0 : terms.reduce(:+)
      solver.assert(sum == @target[counter_idx])
    end

    total = button_vars.reduce(:+)
    solver.minimize(total)

    if solver.satisfiable?
      solver.model[total].to_i
    else
      Float::INFINITY
    end
  end
end

machines = manual.map { |entry| Machine.new(entry) }
puts machines.map(&:find_shortest_presses).sum
