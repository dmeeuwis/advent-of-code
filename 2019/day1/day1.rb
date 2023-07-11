
def fuel(mass)
  ((mass / 3) - 2).floor
end

def fuel_for_fuel(mass)
  f0 = fuel(mass)
  ft = f0

  while f0 > 0
    f0 = fuel(f0)
    if f0 <= 0
      return ft
    end
    ft += f0
  end
end

f = File.open("input.txt")
lineList = f.readlines.map(&:chomp)

fuels = lineList.map { |l| fuel(l.to_i) }
puts("Fuel required: #{fuels.sum}")

fully_fueled = lineList.map { |l| fuel_for_fuel(l.to_i) }
puts("Fuel-fuel required: #{fully_fueled.sum}")
