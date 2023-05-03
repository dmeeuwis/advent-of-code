
with open("data.txt", mode="r") as file:
  data = file.read()

lines = data.split("\n")
print(len(lines))

elves = []
cur_elf = None

for l in lines:
  if cur_elf is None:
      cur_elf = 0

  if len(l) == 0:
    elves.append(cur_elf)
    cur_elf = None
  else:
    cur_elf += int(l)
    
elves.append(cur_elf)

print(elves)
largest = max(elves)
print(largest)

elves.sort()
print(elves)

top_3 = elves[-3:]

print(top_3)
print(sum(top_3))