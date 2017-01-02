module Uno
  class Player
    attr_reader :hand
    attr_reader :name

    def initialize(name)
      @name = name
      @hand = []
    end

    def empty_hand!
      @hand = []
    end

    def put_card_in_hand(card)
      @hand << card
    end

    def take_card_from_hand(card)
      raise PlayerDoesNotHaveThatCard unless has_card?(card)
      hand.delete(card)
    end

    def has_card?(card)
      hand.include? card
    end
  end
end