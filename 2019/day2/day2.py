import sys 
import itertools

with open(sys.argv[1]) as f:
    lineList = f.readlines()

input = list(map(int, lineList[0].split(",")))
state = dict(zip(range(len(input)), input))

def calculate(program):
    pc = 0
    while True:
        op = program[pc]
        #print("Loop", pc, op, program)
        if op == 1:
            program[program[pc+3]] = program[program[pc+1]] + program[program[pc+2]]
            pc += 4
        elif op == 2:
            program[program[pc+3]] = program[program[pc+1]] * program[program[pc+2]]
            pc += 4
        elif op == 99:
            return program

end_state = calculate(state)
print("Part 1 End state:", end_state[0])

def attempt(program, attempt):
    program[1] = attempt[0]
    program[2] = attempt[1]

    out_state = calculate(program)
    if out_state[0] == 19690720:
        return attempt

    return False

attempts = list(itertools.combinations(range(100),2))
for a in attempts:
    state = dict(zip(range(len(input)), input))
    if(attempt(state, a)):
        print("Part 2: found it!", a, (100*a[0] + a[1]))
        sys.exit(0)

print("Part 2: failure, no match found!")
