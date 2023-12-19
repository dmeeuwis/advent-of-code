require 'byebug'

f = File.open(ARGV[0])
lines = f.readlines.map { |l| l.chomp }

$workflows_by_name = {}

workflows = []
lines.each do |line|
  break if line.empty?
  line =~ /^(\w+){(.*)}$/
  name = $1
  rule_line = $2
  rules = rule_line.split(',')

  parsed = rules.map do |r|
    if r[':']
      r =~ /(\w)([><])(\d+):(\w+)/
      rule_target = $1
      rule_compare = $2
      rule_num = $3.to_i
      rule_send_to = $4
      { property: rule_target, op: rule_compare, value: rule_num, send: rule_send_to }
    elsif r == 'A'
      { op: :accept }
    elsif r == 'R'
      { op: :reject }
    else 
      { op: :workflow, value: r }
    end
  end

  $workflows_by_name[name] = parsed
end


parts_lines = lines[$workflows_by_name.size+1..]
parts = parts_lines.map do |line|
  line =~ /^{x=(\d+),m=(\d+),a=(\d+),s=(\d+)}$/
  x, m, a, s = $1.to_i, $2.to_i, $3.to_i, $4.to_i
  { x: x, m: m, a: a, s: s }
end

$ACCEPTED = []
$REJECTED = []

def process part, rule_name, rules
  puts "\t#{part} #{rule_name}"
  rules.each do |r|
    if r[:property]
      val      = part[r[:property].to_sym]
      comp     = r[:op]
      comp_val = r[:value]

      if comp == '>'
        if val > comp_val
          if r[:send] == 'A'
            $ACCEPTED.push part
            return
          elsif r[:send] == 'R'
            $REJECTED.push part
            return
          end
          process(part, r[:send], $workflows_by_name[r[:send]])
          return
        end
      elsif comp == '<'
        if val < comp_val
          if r[:send] == 'A'
            $ACCEPTED.push part
            return
          elsif r[:send] == 'R'
            $REJECTED.push part
            return
          end
          process(part, r[:send], $workflows_by_name[r[:send]])
          return
        end
      end
    elsif r[:op] == :accept
      $ACCEPTED.push part
      return
    elsif r[:op] == :reject
      $REJECTED.push part
      return
    elsif r[:op] == :workflow
      process(part, r[:value], $workflows_by_name[r[:value]])
      return
    end
    puts "\tDidn't match, carrying on to next rule"
  end

  raise "Error: couldn't process part #{part} #{rule_name}"
end

parts.each do |part|
  puts part
  rules = $workflows_by_name['in']
  process part, 'in', rules
end

byebug
sum = 0
$ACCEPTED.each do |part|
  sum += part[:x] + part[:m] + part[:a] + part[:s]
end
puts "Sum is #{sum}"
