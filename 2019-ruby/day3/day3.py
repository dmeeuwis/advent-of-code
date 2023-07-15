import sys
from collections import namedtuple

grid = {}
grid[(0,0)] = 'o'
start = (0,0)

Move = namedtuple('Move', 'movement distance char')

def read_file(f):
    with open(f, 'r') as file:
        return file.read().split()

def parse(line):
    def parse_instruction(txt):
        offsets = { 'R': [0,1], 'D': [1,0], 'L': [0,-1], 'U': [-1,0] }
        movement = offsets[txt[0]]
        distance = int(txt[1:])
        char = '-' if (txt[0] == 'R' or txt[0] == 'L') else '|'
        return Move(movement, distance, char)

    text_instructions = line.split(',')
    instructions = list(map(parse_instruction, text_instructions))
    return instructions

def apply_instruction(grid, current, instruction, intersects, track_points, movements, point_movements):
    nc = current

    for i in range(instruction.distance):
        nc = (nc[0] + instruction.movement[0], nc[1] + instruction.movement[1])
        y, x = nc
        loc = (y, x)
        on_grid = grid.get(loc)

        if on_grid is None:
            grid[loc] = instruction.char
        elif on_grid != instruction.char and not track_points.get(loc):
            grid[loc] = 'X'
            intersects.append(loc)

        track_points[loc] = True

        if not point_movements.get(loc):
            point_movements[loc] = movements

        movements += 1

    return nc, movements

lines = read_file(sys.argv[1])
intersects = []
point_movements = [ {}, {} ]

for line_index, line in enumerate(lines):
    location = start
    track_points = { location: True }
    movements = 1
    for i in parse(line):
        location, movements = apply_instruction(grid, location, i, intersects, track_points, movements, point_movements[line_index])

distances = [abs(x[0]) + abs(x[1]) for x in intersects]
steps = [point_movements[0][loc] + point_movements[1][loc] for loc in intersects]
print("Min distance is", min(distances), "Min steps is", min(steps))
