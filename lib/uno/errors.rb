module Uno
  # Player
  class PlayerDoesNotHaveThatCardError < StandardError; end

  # Game
  class GameHasNotStartedError < StandardError; end
  class GameHasStartedError < StandardError; end
  class NotEnoughPlayersError < StandardError; end
  class PlayerAlreadyInGameError < StandardError; end
  class NotPlayersTurnError < StandardError; end
  class InvalidMoveError < StandardError; end
  class GameIsOverError < StandardError; end
  class NoColorChosenError < StandardError; end
  class InvalidColorChoice < StandardError; end
end