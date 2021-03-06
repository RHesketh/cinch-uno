module Uno
  class Deck
    def self.standard_uno_deck
      deck = []

      Card.colors.each do |color|
        deck << Card.new(:zero, color)

        2.times do
          deck <<  [ Card.new(:one, color),
                     Card.new(:two, color),
                     Card.new(:three, color),
                     Card.new(:four, color),
                     Card.new(:five, color),
                     Card.new(:six, color),
                     Card.new(:seven, color),
                     Card.new(:eight, color),
                     Card.new(:nine, color),
                     Card.new(:draw_two, color),
                     Card.new(:reverse, color),
                     Card.new(:skip, color) ]
        end
      end

      4.times do
        deck << Card.new(:wild)
        deck << Card.new(:wild_draw_four)
      end

      return deck.flatten.reverse
    end
  end
end