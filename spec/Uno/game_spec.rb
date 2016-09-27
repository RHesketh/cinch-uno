require 'spec_helper'

module Uno
  describe Game do
  let(:game) { Uno::Game.new }
    it 'Starts in a :waiting_for_players state' do
      expect(game.state).to be :waiting_for_players
    end
  end
end