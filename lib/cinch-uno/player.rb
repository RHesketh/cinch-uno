module Uno
  class Player
    attr_reader :hand
    attr_reader :name

    def initialize(name)
      @name = name
      @hand = []
    end

    def put_card_in_hand(card)
      @hand << card
    end

    def has_card?(card)
      return true if @hand.any?{|card_in_hand| card_in_hand == card }
      return false
    end
  end
end