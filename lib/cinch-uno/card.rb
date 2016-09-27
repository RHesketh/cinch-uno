module Uno
  class Card
    attr_reader :color
    attr_reader :type

    def initialize(type=nil, color = nil)
      @type = type
      @color = color
    end

    def ==(b)
      return true if (self.color == b.color && self.type == b.type)
      return false
    end
  end
end