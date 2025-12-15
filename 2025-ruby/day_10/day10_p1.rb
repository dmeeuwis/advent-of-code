
def parse_line(line)
  [line[/\[([^\]]+)\]/, 1], line.scan(/\(([^)]+)\)/).flatten, line[/\{([^}]+)\}/, 1]]
end

manual = File.read(ARGV[0]).split("\n").map { |line| parse_line(line) }

class Machine
  def initialize(manual_entry)
    goal_state, buttons, jigs = manual_entry
    @target = goal_state.chars.map { |c| c == '#' ? 1 : 0 }
    @buttons = buttons.map { |b| b.split(',').map(&:to_i) }
    @num_lights = @target.length
  end

  def find_shortest_presses
    num_buttons = @buttons.length
    min_presses = Float::INFINITY

    (0...(2 ** num_buttons)).each do |combo|
      lights = Array.new(@num_lights, 0)
      presses = 0

      num_buttons.times do |i|
        if combo[i] == 1
          presses += 1
          @buttons[i].each { |light_idx| lights[light_idx] ^= 1 }
        end
      end

      min_presses = presses if lights == @target && presses < min_presses
    end

    min_presses
  end
end

machines = manual.map { |entry| Machine.new(entry) }
puts machines.map(&:find_shortest_presses).sum
