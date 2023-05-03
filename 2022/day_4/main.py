with(open("data.txt", "r") as file):
  data = file.read()

lines = data.split("\n")
assignment_pairs = [l.split(",") for l in lines]

contained = list()
for pair in assignment_pairs:
    parts_a = tuple([int(n) for n in pair[0].split('-')])
    parts_b = tuple([int(n) for n in pair[1].split('-')])

    #print(f"{parts_a} and {parts_b}")

    if parts_a[0] <= parts_b[0] and parts_a[1] >= parts_b[1]:
        #print(f"{parts_b} is contained in {parts_a}")
        contained.append(pair)

    elif parts_b[0] <= parts_a[0] and parts_b[1] >= parts_a[1]:
        #print(f"{parts_a} is contained in {parts_b}")
        contained.append(pair)

print(f"Part 1, number of contained pairs: {len(contained)}")

partials = list()
for pair in assignment_pairs:
    parts_a = tuple([int(n) for n in pair[0].split('-')])
    parts_b = tuple([int(n) for n in pair[1].split('-')])

    #print(f"{parts_a} and {parts_b}")

    if parts_b[0] >= parts_a[0] and parts_b[0] <= parts_a[1]:
        #print(f"{parts_a} is partially contained in {parts_b}")
        partials.append(pair)

    elif parts_a[0] >= parts_b[0] and parts_a[0] <= parts_b[1]:
        #print(f"{parts_b} is partially contained in {parts_a}")
        partials.append(pair)

print(f"Part 2, number of partial pairs: {len(partials)}")
