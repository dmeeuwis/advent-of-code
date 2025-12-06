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
    cols[cell_i].push cell
  end
end

soln = cols.map do |col|
  width = col.map { |cell| cell.size }.max
  left_col = col.map do |cell|
    spacing_needed = width - cell.size
    (" " * spacing_needed) + cell
  end

  puts "Translated col to: #{left_col.inspect}"
  numbers = (0..(width-1)).to_a.map do |column_i|
    num = left_col.map { |c| c[column_i] }.join.to_i
    puts "Number #{column_i} is #{num}"
    num
  end

  puts "Got numbers: #{numbers}"

  op = col.pop
  if op == '*'
    numbers.inject(:*)
  elsif op == '+'
    numbers.sum
  else
    raise "Unknown operator #{op}"
  end
end

puts "Soln is #{soln.sum}"
