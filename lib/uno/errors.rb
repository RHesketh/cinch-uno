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
  class InvalidColorChoiceError < StandardError; end
  class WaitingForWD4ResponseError < StandardError; end
  class NoWD4ChallengeActiveError < StandardError; end
end