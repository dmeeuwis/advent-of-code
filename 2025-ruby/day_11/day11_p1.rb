require 'byebug'
lines = File.read(ARGV[0]).split("\n")

dependencies = {}
servers = lines.map do |line|
  parts = line.split(": ")
  server = parts[0]
  deps = parts[1].split(" ")
  dependencies[server] = deps
end

def count_paths(dependencies, current, target)
  return 1 if current == target

  outputs = dependencies[current]
  return 0 if outputs.nil? || outputs.empty?

  outputs.sum do |output|
    count_paths(dependencies, output, target)
  end
end

result = count_paths(dependencies, "you", "out")
puts result
