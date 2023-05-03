def letter_to_number(letter):
  if letter.islower():
    return ord(letter) - ord('a') + 1
  elif letter.isupper():
    return ord(letter) - ord('A') + 27
  else:
    return None

def split_sack(sack):
  chars = int(len(sack)/2)
  return (sack[0:chars], sack[chars:])

def find_common(a, b):
  a_chars = set(a)
  b_chars = set(b)

  common = a_chars.intersection(b_chars)
  return common


with(open("data.txt", mode="r") as file):
  data = file.read()

lines = data.split("\n")

total = 0

for line in lines:
  parts = split_sack(line)
  common = find_common(parts[0], parts[1])  
  value = letter_to_number(common.pop())
  
  total += value

print(f"Part 1 total is {total}")

total_2 = 0
lines.reverse()

while len(lines) > 0:
  a_chars = set(lines.pop())
  b_chars = set(lines.pop())
  c_chars = set(lines.pop())

  common = a_chars.intersection(b_chars).intersection(c_chars)

  total_2 += letter_to_number(common.pop())

print(f"Part 2 total is {total_2}")