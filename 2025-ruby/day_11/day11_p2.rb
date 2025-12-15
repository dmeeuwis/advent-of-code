lines = File.read(ARGV[0]).split("\n")

dependencies = {}
lines.each do |line|
  parts = line.split(": ")
  dependencies[parts[0]] = parts[1].split(" ")
end

def count_paths(dependencies, current, target, required, seen = [], memo = {})
  new_seen = required.include?(current) ? (seen + [current]).sort : seen
  key = [current, new_seen]
  return memo[key] if memo.key?(key)

  if current == target
    memo[key] = new_seen.size == required.size ? 1 : 0
    return memo[key]
  end

  outputs = dependencies[current]
  return memo[key] = 0 if outputs.nil? || outputs.empty?

  memo[key] = outputs.sum { |output| count_paths(dependencies, output, target, required, new_seen, memo) }
end

puts count_paths(dependencies, "svr", "out", ["dac", "fft"])
