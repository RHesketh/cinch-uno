require 'spec_helper'

module Uno
  describe Game do
    let(:fake_deck) {[Uno::Card.new, Uno::Card.new, Uno::Card.new]}

    let(:game) { Uno::Game.new(deck: fake_deck) }

    it 'Starts in a :waiting_to_start state' do
      expect(game.state).to be :waiting_to_start
    end

    context "While waiting for players..." do
      it "Don't start the game unless there are at least 2 players" do 
        expect{
          game.start
        }.to raise_error(Game::NotEnoughPlayers)
      end

      it "Allow multiple players to join the game" do 
        game.add_player("Char")
        game.add_player("angelphish")

        expect(game.players).to be_an Array

        expect(game.players[0]).to eq "Char"
        expect(game.players[1]).to eq "angelphish"

        expect(game.players.length).to eq 2
      end

      it "Do nothing if a player tries to join twice" do 
        game.add_player("Char")
        game.add_player("Char")

        expect(game.players.length).to eq 1
      end
    end

    context "When the game is started with at least two players..." do
      let(:fake_players) { { "Char" => {}, "angelphish" => {} } }
      let(:game){ Uno::Game.new(players: fake_players)}

      it "Begin in a :waiting_for_player state" do 
        game.start
        expect(game.state).to be :waiting_for_player
      end

      it "Generate own deck if not given one" do 
        expect(Uno::Deck).to receive(:generate).and_call_original

        game.start
      end

      it "Shuffle the deck" do
        new_game = Uno::Game.new(deck: fake_deck, players: fake_players)

        expect(fake_deck).to receive(:shuffle!)

        new_game.start
      end

      it "Place one card from the deck on the discard pile" do
        new_game = Uno::Game.new(deck: fake_deck, players: fake_players)
        new_game.start

        expect(new_game.discard_pile).to be_an Array
        expect(new_game.discard_pile.length).to eq 1
        expect(new_game.discard_pile.first).to be_a Uno::Card
      end

      it "Place two cards from the deck into a draw pile" do 
        new_game = Uno::Game.new(deck: fake_deck, players: fake_players)
        new_game.start

        expect(new_game.draw_pile).to be_an Array
        expect(new_game.draw_pile.length).to eq 2
        expect(new_game.draw_pile.first).to be_a Uno::Card
      end

      it "Determine a play order" do 
        game.start

        expect(game.play_order).to be_an Array
        expect(game.play_order.length).to eq 2

        expect(game.current_player).to be_a String
        expect(game.current_player).to eq game.play_order.first
      end
    end
  end
end