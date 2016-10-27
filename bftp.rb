include Math
require 'set'
require 'pry'

class Node < String
	attr_accessor :left, :right

	def initialize(string="")
		@left, @right = "", ""
		super
	end

	def all
		@left + self + @right
	end
end

class Fixnum
	def to_node
		string = self.to_s
		Node.new(string)
	end
end

# CONSTANTS ----------------------

# Interesting transcendental numbers, and positive, zero, and negative values have been included.
# 'Interesting' is purely subjective.

# Dottie Number
# http://mathworld.wolfram.com/DottieNumber.html
DOTTIE = 0.7390851332151607

# Euler-Mascheroni Constant
# http://mathworld.wolfram.com/Euler-MascheroniConstant.html
EMC = 0.5772156649015329

# Catalan's Constant
# http://mathworld.wolfram.com/CatalansConstant.html
CATALAN = 0.915965594177219

# i raised to the power of i
# https://www.youtube.com/watch?v=zmQfvdPTyco
I_TO_I = 0.20787957635 

# Here, 'numbers' are of type Node to convey that they can contain extra info to their left or right.
NUMBERS = [ 
	"n", # The iteration of the series, incremented each time.
	"PI", 
	"E", 
	"DOTTIE", 
	"EMC", 
	"CATALAN", 
	"I_TO_I", 
	"0.0", 
	"1.0", 
	"-1.0" 
]

# NODES = NUMBERS.map(&:to_node)

OPERATORS = [ 
	"+", 
	"-", 
	"*", 
	"/", 
	"%", 
	"**" 
]

GROUPINGS = [
	["(",      ")"],
	["sin(",   ")"],
	["cos(",   ")"],
	["tan(",   ")"],
	["sqrt(",  ")"],
	["cbrt(",  ")"],
	["sinh(",  ")"],
	["cosh(",  ")"],
	["tanh(",  ")"],
	["gamma(", ")"],
	["abs(",   ")"],
	["log(",   ")"],
	["log2(",  ")"],
]

PRIMES_TO_CHECK = Set.new([2.0, 3.0, 5.0, 7.0, 11.0, 13.0, 17.0, 19.0, 23.0, 29.0])

# --------------------------------

# This is an arbitrary number which allows for more groupings than the saturation limit.
# Example: in a 3-node statement A*B+C, the saturation limit is 3 groupings: (((A)*B)+C),
# which is nesting_level 1. Nesting level 2 would allow for 6 groupings, like this: (((A)*((B))+(C)))
# This is useful since groupings can also be of this sort: cos(tan(A*B)+C), or this: gamma(A*sqrt(B+C))
nesting_level = 1

iteration_limit = 20

precision_level = 0.0001

filename = "#{Time.now.to_i}_BFTPoutput.txt"

# Number of nodes will increment ad infinitum.
# TODO: Create looping logic here that iterates upward by 1 forever.
number_of_nodes = 3

continue = true

while continue

	groupings_multiplier = number_of_nodes * nesting_level

	# Operators go between nodes in statements. A + B - C. Therefore they are one fewer.
	number_of_operators = number_of_nodes - 1

	# All possible permutations of nodes and operators, separately.
	# "numbers_combos" must include 'n'.
	# Returns Enumerator objects.
	numbers_combos = NUMBERS.repeated_permutation(number_of_nodes)
	operators_combos = OPERATORS.repeated_permutation(number_of_operators)

	# Returns all possible positions of nodes around which a pair of parentheses could be placed.
	# Example: in a 3-node statement "A*B+C", A has position 0, B position 1, C position 2,
	# and its possible groupings are [[0,0], [0,1], [0,2], [1,1], [1,2], [2,2]],
	# which map respectively to (A)*B+C, (A*B)+C, (A*B+C), A*(B)+C, A*(B+C), and A*B+(C).
	# The first integer in each array places "(" and the second places ")".
	# Note that only one of those groupings could conceivably change the statement's result. C'est la programming.
	node_positions = [*0...number_of_nodes]
	paren_pair_position_configurations = node_positions.repeated_combination(2).to_a.push([nil, nil])
	multiple_paren_pair_positions_configurations = paren_pair_position_configurations.repeated_permutation(groupings_multiplier)

	# All permutations of grouping types (cos, tan, sqrt, etc.) for however many nodes the statement contains.
	groupings_combos = GROUPINGS.repeated_permutation(groupings_multiplier)

	# This is the process.
	## 0. For each operators_combo:
	## 1. For each nodes_combo:
	## 2. For each groupings_combo:
	## 3. For each multiple_paren_pair_positions_configuration:
	## 4. Create array with (number_of_nodes) Nodes corresponding to nodes_combo
	# 5. Iterate simultaneously over each two-element array in multiple_paren_pair_position_configuration and groupings_combo
	# 6. paren_two_element_array.first is the position of the Node in the array
	# 7. groupings_combo.first is the string to be prepended to Node.left
	# 8. paren_two_element_array.last is the position of the Node in the array
	# 9. groupings_combo.last is the string to be added to Node.right
	#10. zip this array with the operators_combo, flatten
	#11. join all nodes, join into string
	#12. eval string several times. N is incremented each time.
	#13. save answer set into array. round decimal answers to integer val if very close to integer.
	#14. implement error handling -- if math error (divide by 0, etc), next iteration.
	#15. check if answer set contains first ten primes (2, 3, 5, 7, 11, 13, 17, 19, 23, 29)
	#16. if primes are in answer set, save eval(string) and answer_set to DB.

	evaluated_statements = 0
	number_of_statements = (
		operators_combos.to_a.length
		) * (
		numbers_combos.to_a.select { |combo| combo.include?('n') }.length
		) * (
		groupings_combos.to_a.length
		) * (
		multiple_paren_pair_positions_configurations.to_a.length
		)

	operators_combos.each do |operators_combo|
		numbers_combos.each do |numbers_combo|
			next if !numbers_combo.include?('n') # Important to have an incremental value in the statements.
			groupings_combos.each do |groupings_combo|
				multiple_paren_pair_positions_configurations.each do |positions_combo|
					nodes_array = []
					numbers_combo.each do |number_string|
						nodes_array << Node.new(number_string)
					end

					groupings_multiplier.times do |n|
						
						positions_pair = positions_combo[n]
						parens_pair = groupings_combo[n]
						
						node_left_position  = positions_pair.first
						node_right_position = positions_pair.last
						
						left_string  = parens_pair.first
						right_string = parens_pair.last

						#binding.pry

						nodes_array[node_left_position].left.prepend(left_string) if node_left_position
						nodes_array[node_right_position].right += right_string if node_right_position
					end

					nodes_operators_array = nodes_array.zip(operators_combo).flatten.compact

					statement_string = ""
					nodes_operators_array.each do |element|
						if element.is_a?(Node)
							element_string = element.all
						else
							element_string = element
						end	
						statement_string += element_string
					end

					n = 0
					answer_set = Set.new
					while n <= iteration_limit
						begin								
							result = eval(statement_string)
						rescue
							result = nil
						else
							# If it's even legal to do this,
							if result.is_a?(Fixnum)
								# Round result to closest integer if it's close enough for jazz.
								result = result.round.to_f if result.modulo(1) <= precision_level	
							end
						ensure
							answer_set << result
							n += 1
						end
					end

					if PRIMES_TO_CHECK.proper_subset?(answer_set)						
						content = "#{statement_string}\n#{[*set]}\n\n"
						File.write(filename, content)
						puts "Found a statement that outputs prime numbers! Writing to file."
					end

					evaluated_statements += 1
					percent_completed = ((evaluated_statements / number_of_statements.to_f) * 100).round(5)
					print "#{percent_completed}% of #{number_of_statements} #{number_of_nodes}-node statements evaluated." + "\r"
					$stdout.flush
				end
			end  
		end			 
	end

	loop do
		puts "All #{number_of_nodes}-node statements evaluated. Start evaluating #{number_of_nodes + 1}-node statements now? (Y/N)"
		user_input = gets.chomp
		if user_input.upcase == "Y"
			number_of_nodes += 1
			break
		elsif user_input.upcase == "N"
			puts "Exiting"
			continue = false
			break
		else
			puts "Invalid. Please choose again. (Y/N)"
		end
	end
end