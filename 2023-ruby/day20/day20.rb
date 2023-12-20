require 'byebug'

def build(line)
  line =~ /([\w%&]+) -> (.*)$/
  name = $1
  dests = $2.split(', ')
  if name[0] == '%'
    FlipFlop.new name[1..], dests
  elsif name[0] == '&'
    Conjunction.new name[1..], dests
  elsif name[0..8] == 'broadcast'
    Broadcast.new name, dests
  else
    raise "Don't know what to do with line: #{line}"
  end
end

class FlipFlop
  attr_reader :name
  def initialize(name, dests)
    @name = name
    @state = false
    @dests = dests
    puts "FlipFlop #{@name} -> #{@dests.join(', ')}"
  end

  def pulse(input, pulse)
    puts "\t! FF #{@name} from #{input} #{pulse}"
    return if input == 0
    if input == 1
      @state = !@state
    end

    @dests.each do |d|
      n = $registry[d]
      n.pulse @name, @state
    end
  end
end

class Conjunction
  attr_reader :name
  def initialize(name, dests)
    @name = name
    @state = {}
    @dests = dests
    puts "Conjunction #{@name} -> #{@dests.join(', ')}"
  end

  def pulse(input, pulse)
    puts "\t! CO #{@name} from #{input} #{pulse}"
    @state[input] = pulse
    @dests.each do |d|
      n = $registry[d]
      p = !(@state.all? true)
      n.pulse @name, p
    end
  end
end

class Broadcast
  attr_reader :name
  def initialize(name, dests)
    @name = name
    @dests = dests
    puts "Broadcast #{@name} -> #{@dests.join(', ')}"
  end

  def pulse(input, pulse)
    puts "\t! BC #{@name} from #{input} #{pulse}"
    @dests.each do |d|
      n = $registry[d]
      n.pulse(name, pulse)
    end
  end
end

f = File.open(ARGV[0])
lines = f.readlines.map { |l| l.chomp }

$registry = {}
lines.each do |l|
  node = build l
  $registry[node.name] = node
end

puts
puts
$registry['broadcaster'].pulse(nil, false)
puts
byebug
