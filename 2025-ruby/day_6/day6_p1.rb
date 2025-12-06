lines = File.read(ARGV[0])

rows = lines.split("\n")
cols = []

rows.each_with_index do |row, row_i|
  puts "Looking at row #{row}"
  cells = row.strip.split(/\s+/)
  puts "Cells: #{cells}"
  cells.each_with_index do |cell, cell_i|
    puts "Looking at cell #{cell} #{cell_i}"
    cols[cell_i] ||= []
    num = (cell == '*' || cell == '+') ? cell : cell.to_i
    cols[cell_i].push num
  end
end

soln = cols.map do |col|
  puts col.inspect
  op = col.pop
  if op == '*'
    col.inject(:*)
  elsif op == '+'
    col.sum
  else
    raise "Unknown operator #{op}"
  end
end

puts "Soln is #{soln.sum}"
