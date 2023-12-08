require 'set'
require 'byebug'

CARDS = %w(A K Q T 9 8 7 6 5 4 3 2 J)
POWER = {}
CARDS.each_with_index { |c, i| POWER[c] = CARDS.size - i }

# return a map with a count of all characters in a string
def count_chars(i)
  i.chars.reduce(Hash.new(0)) { |h, c| h[c] += 1; h }
end

def five_of_a_kind(h) 
  chars = count_chars h
  return chars.values.sort == [5]
end

def four_of_a_kind(h)
  chars = count_chars h
  return chars.values.sort == [1,4]
end

def full_house(h) 
  chars = count_chars h
  return chars.values.sort == [2,3]
end

def three_of_a_kind(h)
  chars = count_chars h
  return chars.values.sort == [1,1,3]
end

def two_pair(h)
  chars = count_chars h
  return chars.values.sort == [1,2,2]
end

def one_pair(h)
  chars = count_chars h
  return chars.values.sort == [1, 1, 1, 2]
end

def high_card(h)
  chars = count_chars h
  return chars.values.sort == [1, 1, 1, 1, 1]
end

HANDS = [ method(:five_of_a_kind), method(:four_of_a_kind), method(:full_house), 
          method(:three_of_a_kind), method(:two_pair), method(:one_pair), method(:high_card) ].reverse

def score_hand(hand)
  possible_rating = []
  CARDS.each do |card|
    possible_hand = hand.gsub('J', card)

    HANDS.each_with_index do |hand_method, index|
      h = hand_method.call(possible_hand)
      if h
        possible_rating.push [possible_hand, hand_method, h]
      end
    end
  end
  possible_rating.sort_by! do |rating|
    HANDS.index rating[1]
  end

  puts "Selected #{possible_rating[0]} for hand #{hand}"
  HANDS.index possible_rating.last[1]
end

f = File.open(ARGV[0])
lines = f.readlines.map { |l| l.chomp }
rounds = lines.map do |l| 
  parts = l.split(" ")
  [parts[0], score_hand(parts[0]), parts[1].to_i]
end

rounds.sort_by! do |round| 
  r = round[0]
  power_map = [ round[1], POWER[r[0]], POWER[r[1]], POWER[r[2]], POWER[r[3]], POWER[r[4]] ] 
  power_map
end

sum = 0

rounds.each_with_index do |round, index|
  rank = index + 1
  score = round[2] * rank
  puts "#{round}: score=#{score}, rank=#{rank}, sum=>#{sum+score}"
  sum += score
end

puts "Sum is #{sum}"