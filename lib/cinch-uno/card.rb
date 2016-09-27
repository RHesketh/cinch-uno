module Uno
  class Card
    attr_reader :color
    attr_reader :type

    def initialize(type=nil, color = nil)
      @type = type
      @color = color
    end
  end
end