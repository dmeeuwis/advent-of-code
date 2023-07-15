with(open("data.txt", mode="r") as file):
  data = file.read()

# a = rock, b = paper, c = scissors
# x = rock, y = paper, z = scissors
rules = {
  ('A', 'X'): 4,
  ('A', 'Y'): 8,
  ('A', 'Z'): 3,

  ('B', 'X'): 1,
  ('B', 'Y'): 5,
  ('B', 'Z'): 9,

  ('C', 'X'): 7,
  ('C', 'Y'): 2,
  ('C', 'Z'): 6
}

rows = data.split("\n")
print(f"{len(rows)} rows found.")

score = 0

for row in rows:
  r = tuple(row.split(" "))
  score += rules[r]
  
print(f"Final score for part A is {score}")

# a = rock, b = paper, c = scissors
# x = lose, y = draw, z = win
rules_b = {
  ('A', 'X'): 3, #scissors
  ('A', 'Y'): 4, #rock
  ('A', 'Z'): 8, #paper

  ('B', 'X'): 1, #rock
  ('B', 'Y'): 5, #paper
  ('B', 'Z'): 9, #scissors

  ('C', 'X'): 2,
  ('C', 'Y'): 6,
  ('C', 'Z'): 7
}

score_b = 0

for row in rows:
  r = tuple(row.split(" "))
  score_b += rules_b[r]
  
print(f"Final score for part B is {score_b}")
