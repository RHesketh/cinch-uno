require 'spec_helper'

module Uno
  describe Game do
  let(:game) { Uno::Game.new }
    it 'Starts in a :waiting_for_players state' do
      expect(game.state).to be :waiting_to_start
    end

    context "while waiting for players" do
      it "don't start the game unless there are at least 2 players" do 
        expect{
          game.start
        }.to raise_error(Game::NotEnoughPlayers)
      end

      it "multiple players can join the game" do 
        game.add_player("Char")
        game.add_player("angelphish")

        expect(game.players).to be_an Array

        expect(game.players[0]).to eq "Char"
        expect(game.players[1]).to eq "angelphish"

        expect(game.players.length).to eq 2
      end

      it "do nothing if a player tries to join twice" do 
        game.add_player("Char")
        game.add_player("Char")

        expect(game.players.length).to eq 1
      end
    end

    context "When the game is started with at least two players" do
      before(:each) do 
        game.add_player("Char")
        game.add_player("angelphish")

        game.start
      end

      it "should be in a :waiting_for_player state" do 
        expect(game.state).to be :waiting_for_player
      end
    end
  end
end