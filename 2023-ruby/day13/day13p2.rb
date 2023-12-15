require 'byebug'
require 'set'

f = File.open(ARGV[0])
maps = []
current = []
f.readlines.each do |l| 
  l.chomp!
  if l.empty?
    maps.push current
    current = []
    next
  end

  current.push l
end
maps.push current
current = nil

def reflect_col? map, check_index, smudge
  puts "reflect_col? #{check_index}"

  cols_left = check_index
  cols_right = map[0].size - check_index
  cols_to_check = [cols_left, cols_right].min
  puts "cols_to_check: #{cols_to_check}"
  return false if cols_to_check <= 0

  diffs = []
  (0..(map[0].size)).each do |col_i|
    #puts "Checking col #{col_i} of #{map.size}"
    col_lf = check_index + col_i - 1
    col_rt = check_index - col_i 

    (0..(map.size-1)).each do |row_i|
      #puts "Checking row #{row_i} of #{map.size}"
      if map[row_i][col_lf] != map[row_i][col_rt]
        diffs.push [row_i, col_lf]
        #puts "Saw cols diff! #{row_i},#{col_lf} #{map[row_i][col_lf]} != #{row_i},#{col_rt} #{map[row_i][col_rt]}"
      end
    end
  end

  puts "Diffs.size = #{diffs.size}"

  if !smudge && diffs.size == 1
    puts "-------------------> Found a COL smudge! Correcting #{diffs[0]} to ."
    map[row_i][col_i] = map[row_i][col_i] == '#' ? '.' : '#'
    return reflect_col? map, check_index, false
  end

  if smudge && diffs.size == 0
    puts "Found a COL reflection at row = #{check_index}!!!!! <--------------------------" if diffs == 0
  end
  diffs == []
end

def print_map(map)
  map.each do |r|
    puts r
  end
end

def reflect_row? map, check_index, smudge

  puts "========== COLS #{check_index} =============="
  cols_to_check = [map.size - check_index, check_index].min
  #puts "cols_to_check: #{cols_to_check}"
  return false if cols_to_check <= 0

  diffs = []
  (0..cols_to_check).each do |row_i|
    row_up = check_index + row_i - 1
    row_dn = check_index - row_i 

    (0..(map[row_up].size)).each do |col_i|
      if map[row_up][col_i] != map[row_dn][col_i]
        diffs.push [row_up, col_i]
        puts "Saw diff! #{row_up},#{col_i} #{map[row_up][col_i]} != #{row_dn},#{col_i} #{map[row_up][col_i]}"
      end
    end
  end

  byebug if check_index == 3
  puts "Diffs.size = #{diffs.size}"
  puts "========== ROWS #{check_index} =============="

  if smudge && diffs.size == 1
    row_i, col_i = diffs[0]
    replace = map[row_i][col_i] == '#' ? '.' : '#'
    puts "------------------> Found a ROW smudge at #{check_index}! Correcting #{row_i}, #{col_i} #{map[row_i][col_i]} to #{replace}"
    print_map map
    map[row_i][col_i] = replace
    puts
    print_map map
    return reflect_row? map, check_index, false
  end

  if !smudge && diffs.size == 0
    puts "Found a ROW reflection at #{check_index}!!!!! <--------------------------" if diffs == 0
  end
  diffs == 0
end

def find_reflection(map)
  # try from 1 to n-1, calc differences between sides
  puts
  puts
  print_map map

  # cols
  (1..map[0].size).each do |n|
    if reflect_col?(map, n, true)
      add = n
      puts "adding #{add}"
      return add
    end
  end

  #puts "Rows"
  (1..map.size).each do |n|
    if reflect_row?(map, n, true) 
      add = n * 100
      puts "adding #{add}"
      return add
    end
  end

  puts "^^^^^^^^^^^^^ No reflection!"
  raise "No reflection!"
end

sums = maps.map { |m| find_reflection m }
sum = sums.sum
puts "Sum is #{sum}"
