module Uno
  class Card
    attr_accessor :color
    attr_reader :type

    def initialize(type=nil, color = nil)
      @type = type
      @color = color
    end

    def ==(b)
      return true if (self.color == b.color && self.type == b.type)
      return false
    end

    def self.colors
      [:red, :green, :blue, :yellow]
    end

    def wild?
      return true if self.type == :wild
      return true if self.type == :wild_draw_four
      return false
    end
  end
end