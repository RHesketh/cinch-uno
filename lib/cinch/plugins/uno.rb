module Cinch
	module Plugins
		# Interfaces with Cinch and IRC chatters
		class Uno
			include Cinch::Plugin
			set plugin_name: "Uno"

			match /fart/i, method: :help

			def help(m, plugin)
				say ("Fart.")
			end
		end
	end
end

module Uno
	# Holds the state of a game in progress
	class Game

	end

	class Deck
		def initialize
			# Generate each of the cards
		end
	end

	class Card
		# :type, :color
	end
end