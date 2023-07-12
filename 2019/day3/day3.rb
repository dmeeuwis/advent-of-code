require 'set' 

grid = {}
grid[[0,0]] = 'o'
start = [0,0]

class Move 
  attr_accessor :distance, :movement, :char
  def initialize(movement, distance, char)
    @movement = movement
    @distance = distance
    @char = char
  end

  def to_s
    "movement=#{movement} distance=#{distance} char=#{char}"
  end
end

OFFSETS = { 'R' => [0,1], 'D' => [1,0], 'L' => [0,-1], 'U' => [-1,0] }
def parse(line)
  text_instructions = line.split ','
  instructions = text_instructions.map do |txt| 
    movement = OFFSETS[txt[0]]
    distance = txt[1..].to_i
    char = (txt[0] == 'R' or txt[0] == 'L') ? '-' : '|'
    Move.new(movement, distance, char)
  end
end

def apply_instruction(grid, pos, instruction, intersects, visited, movements, point_movements)
  instruction.distance.times do
    pos = [pos[0] + instruction.movement[0], pos[1] + instruction.movement[1]]
    y, x = pos
    loc = [y, x]

    if grid[loc].nil?
      grid[loc] = instruction.char
    elsif grid[loc] != instruction.char and not visited.include? loc
      grid[loc] = 'X'
      intersects.append(loc)
    end

    visited.add loc

    if not point_movements[loc]
      point_movements[loc] = movements
    end

    movements += 1
  end

  return pos, movements
end


f = File.open ARGV[0]
lines = f.readlines
intersects = []
point_movements = [ {}, {} ]

lines.each_with_index do |line, line_index|
  location = start
  visited = Set[location]
  movements = 1
  for instruction in parse(line)
    puts "Instruction: #{instruction}"
    location, movements = apply_instruction(grid, location, instruction, intersects, visited, movements, point_movements[line_index])
  end
end

puts "Intersects are #{intersects}"

distances = intersects.map { |x|  x[0].abs + x[1].abs }
steps = intersects.map { |loc| point_movements[0][loc] + point_movements[1][loc] }
puts "Min distance is #{distances.min} Min steps is #{steps.min}"
