require 'byebug'

lines = File.readlines ARGV[0]
reports = lines.map { |line| line.strip.split(/\s+/).map(&:to_i) }

class Array
  def pairs
    self.each_cons(2)
  end
end

def safe?(report)
  report.each_with_index do |val, i|
    next if i == report.size - 1
    if (report[i] - report[i+1]).abs > 3
      puts "Found unsafe pair: #{report[i]} and #{report[i+1]}"
      return false
    end


    if report[i] == report[i+1]
      puts "Found unsafe pair: #{report[i]} and #{report[i+1]}"
      return false
    end 
  end

  all_ascending = report.pairs.all? { |a, b| a < b }
  all_descending = report.pairs.all? { |a, b| a > b }

  if all_ascending || all_descending
    return true
  else 
    puts "Found non-ascending or non-descending pair: #{report}"
    return false
  end
end

count = 0
reports.each do |report|
  puts "Report: #{report} is safe? #{safe?(report)}"
  count += 1 if safe?(report)
end

puts "Saw #{count} safe reports"