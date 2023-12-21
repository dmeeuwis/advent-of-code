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
  attr_reader :state
  def initialize(name, dests)
    @name = name
    @state = false
    @dests = dests
    #puts "FlipFlop #{@name} -> #{@dests.join(', ')}"
  end

  def pulse(input, pulse)
    #puts "#{input} #{pulse} -> #{name}"
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
    #puts "Conjunction #{@name} -> #{@dests.join(', ')}"
  end

  def pulse(input, pulse)
    #puts "#{input} #{pulse} -> #{name}"
    if $specials.include?(@name) && pulse == false
      puts "#{@name} saw #{pulse} pulse at step #{$presses}"
      $specials_low_counts[@name] += 1

      all = $specials_low_counts.keys.all? { |k| $specials_low_counts[k] > 0 }
      if all
        puts "All specials have seen a low! at step #{$presses}"
        exit
      end
    end
    @state[input] = pulse
    @dests.each do |d|
      $queue.push [d, @name, nil]
    end
  end

  def late_pulse
    all_inputs_present = $inputs[name].size == @state.size
    !(all_inputs_present && @state.values.all?(true))
  end

  def inputs
    @state
  end
end

class Broadcast
  attr_reader :name
  def initialize(name, dests)
    @name = name
    @dests = dests
    #puts "Broadcast #{@name} -> #{@dests.join(', ')}"
  end

  def pulse(input, pulse)
    #puts "#{input} #{pulse} -> #{name}"
    @dests.each do |d|
      $queue.push [d, @name, pulse]
    end
  end
end

class Untyped
  attr_reader :name
  def initialize(name)
    @name = name
    #puts "Untype module #{name}"
  end

  def pulse(input, pulse)
    #puts "#{input} #{pulse} -> #{name}"
    @last = pulse
  end

  def last
    @last
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

    if $registry[work[1]].class == Conjunction
      work[2] = $registry[work[1]].late_pulse
    end
    byebug if work[2].nil?
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
puts "Starting work!"
puts

$specials = ['vr', 'pf', 'ts', 'xd']
$specials_low_counts = {'vr' => 0, 'pf' => 0, 'ts' => 0, 'xd'=>0}

$presses = 0
while true
  $registry['broadcaster'].pulse(nil, false)
  work
  $presses += 1
  puts $presses if $presses % 1_000_000 == 0

  #        vr->kr, pf->pm  ts->dl, xd->vk
  #inputs = ['ks', 'pm', 'dl', 'vk']
  #$specials.each do |k|
  #  if $registry[k].late_pulse == true
  #    puts "#{k} is high at #{$presses}"    
  #  end
  #end

  #if $registry['dt'].late_pulse == false
  #  puts "dt high at #{$presses}"
  #end

#  if $registry['rx'].late_pulse == false
#    puts "rx low at #{presses}"
#  end
end

