import sys
from collections import namedtuple

GRID_SIZE = 20000
#GRID_SIZE = 600
start = (int(GRID_SIZE/2), int(GRID_SIZE/2))

grid = [ ['.' for j in range(GRID_SIZE)] for i in range(GRID_SIZE)]
grid[start[0]][start[1]] = 'o'

Move = namedtuple('Move', 'movement distance char')

def read_file(f):
    with open(f, 'r') as file:
        return file.read().split()

def print_grid(g):
    for line in g:
        print(''.join(line))

def parse(line):
    def parse_instruction(txt):
        offsets = { 'R': [0,1], 'D': [1,0], 'L': [0,-1], 'U': [-1,0] }
        movement = offsets[txt[0]]
        distance = int(txt[1:])
        char = '-' if (txt[0] == 'R' or txt[0] == 'L') else '|'
        print("Parsing:", txt[0], char)
        return Move(movement, distance, char)

    text_instructions = line.split(',')
    instructions = list(map(parse_instruction, text_instructions))
    return instructions

def apply_instruction(grid, current, instruction, intersects, track_points, movements, point_movements):
    print(instruction)
    nc = current

    for i in range(instruction.distance):
        nc = (nc[0] + instruction.movement[0], nc[1] + instruction.movement[1])
        y, x = nc
        loc = (y, x)

        if grid[y][x] == '.':
            grid[y][x] = instruction.char
        elif grid[y][x] != instruction.char and not track_points.get( (y,x) ):
            grid[y][x] = 'X'
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


print_grid(grid)

intersects_adjusted = [ [x[0] - start[0], x[1] - start[1]] for x in intersects]
distances = [abs(x[0]) + abs(x[1]) for x in intersects_adjusted]
print("Line 1 points:", point_movements[0])
#print("Line 2 points:", point_movements[1])
print("Intersects", intersects)
steps = [point_movements[0][loc] + point_movements[1][loc] for loc in intersects]
print(intersects_adjusted)
print(distances)
print(steps)
print("Min distance is", min(distances))
print("Min steps is", min(steps))
