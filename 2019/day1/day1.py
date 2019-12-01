import math

def fuel(mass):
    return math.floor(mass / 3) - 2

def fuel_for_fuel(mass):
    f0 = fuel(mass)
    ft = f0

    while f0 > 0:
        f0 = fuel(f0)
        if(f0 <= 0):
            return ft
        ft += f0


with open("input.txt") as f:
    lineList = f.readlines()

fuels = map(lambda l: fuel(int(l)), lineList)
print("Fuel required:", sum(fuels))

fully_fueled = map(lambda l: fuel_for_fuel(int(l)), lineList)
print("Fuel-fuel required:", int(sum(fully_fueled)))
