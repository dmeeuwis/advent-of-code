require 'byebug'

def build(line)
  line =~ /([\w%&]+) -> (.*)$/
  tname = $1
  dests = $2.split(', ')
  node = if tname[0] == '%'
    name = tname[1..]
    FlipFlop.new name, dests
  elsif tname[0] == '&'
    name = tname[1..]
    Conjunction.new name, dests
  elsif tname[0..8] == 'broadcast'
    name = tname
    Broadcast.new name, dests
  else
    raise "Don't know what to do with line: #{line}"
  end

  dests.each do |d|
    $inputs[d].push name
  end

  node
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
    puts "#{input} #{pulse} -> #{name}"
    return if pulse == true
    if pulse == false
      @state = !@state
    end

    @dests.each do |d|
      $queue.push [d, @name, @state]
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
    puts "#{input} #{pulse} -> #{name}"
    @state[input] = pulse
    @dests.each do |d|
      all_inputs_present = $inputs[name].size == @state.size
      p = !(all_inputs_present && @state.values.all?(true))
      $queue.push [d, @name, p]
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
    puts "#{input} #{pulse} -> #{name}"
    @dests.each do |d|
      $queue.push [d, @name, pulse]
    end
  end
end

class Untyped
  attr_reader :name
  def initialize(name)
    @name = name
    puts "Untype module #{name}"
  end

  def pulse(input, pulse)
    puts "#{input} #{pulse} -> #{name}"
  end
end

PULSE_COUNTS = { false => 0, true => 0 }

def work
  while !($queue.empty?)
    work = $queue.pop
    node = $registry[work[0]]
    if node.nil?
      node = Untyped.new work[0] 
    end

    PULSE_COUNTS[work[2]] += 1
    node.pulse(work[1], work[2])
  end
end

f = File.open(ARGV[0])
lines = f.readlines.map { |l| l.chomp }

$queue = Queue.new
$registry = {}
$inputs = Hash.new { |h, k| h[k] = [] }
lines.each do |l|
  node = build l
  $registry[node.name] = node
end
puts "Inputs hash: #{$inputs}"


puts
puts
puts "Ready to start work!"
puts
puts
PRESSES = 1000

PRESSES.times do
  PULSE_COUNTS[false] += 1
  $registry['broadcaster'].pulse(nil, false)
  work
  puts 
  puts 
end

puts "Low pulses: #{PULSE_COUNTS[false]} x high pulses #{PULSE_COUNTS[true]} = #{PULSE_COUNTS[false] * PULSE_COUNTS[true]}"
