lines = File.read(ARGV[0])

rows = lines.split("\n")

max_len = rows.map(&:length).max
separator_columns = []
(0...max_len).each do |i|
  if rows.all? { |row| i >= row.length || row[i] == ' ' }
    separator_columns << i
  end
end

cols = []
rows.each_with_index do |row, row_i|
  puts "Looking at row #{row.inspect}"

  cells = []
  start = 0
  separator_columns.each do |sep|
    cells << row[start...sep] if start < sep
    start = sep + 1
  end
  cells << row[start...max_len] if start < max_len

  puts "Cells: #{cells.inspect}"
  cells.each_with_index do |cell, cell_i|
    puts "Looking at cell #{cell.inspect} #{cell_i}"
    cols[cell_i] ||= []
    cols[cell_i].push cell
  end
end

soln = cols.map do |col|
  op = col.pop.strip

  width = col[0].size

  puts "Number cells: #{col.inspect}"
  numbers = (0..(width-1)).to_a.reverse.map do |column_i|
    num = col.map { |c| c[column_i] }.join.to_i
    puts "Number #{column_i} is #{num}"
    num
  end

  puts "Got numbers: #{numbers}, op: #{op}"

  if op == '*'
    numbers.inject(:*)
  elsif op == '+'
    numbers.sum
  else
    raise "Unknown operator #{op}"
  end
end

puts "Soln is #{soln.sum}"
