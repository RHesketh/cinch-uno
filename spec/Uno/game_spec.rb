require 'spec_helper'

module Uno
  describe Game do
    let(:fake_deck) {
      array = []
      20.times do
        array << Uno::Card.new
      end

      array
    }

    let(:game) { Uno::Game.new(deck: fake_deck) }

    it 'Starts in a :waiting_to_start state' do
      expect(game.state).to be :waiting_to_start
    end

    context "While waiting to start..." do
      it "Don't start the game unless there are at least 2 players" do 
        expect{
          game.start
        }.to raise_error(Game::NotEnoughPlayers)
      end

      it "Allow multiple players to join the game" do 
        game.add_player("Char")
        game.add_player("angelphish")

        expect(game.players).to be_a Hash

        expect(game.players.keys[0]).to eq "Char"
        expect(game.players.keys[1]).to eq "angelphish"

        expect(game.players.length).to eq 2
      end

      it "Do nothing if a player tries to join twice" do 
        game.add_player("Char")
        game.add_player("Char")

        expect(game.players.length).to eq 1
      end

      it "Moves are not accepted" do 
        expect{
          game.play("foo12", Uno::Card.new)
        }.to raise_error(Game::GameHasNotStarted)
      end
    end

    context "When the game is started with at least two players..." do
      let(:fake_players) { { "Char" => {}, "angelphish" => {} } }
      let(:game){ Uno::Game.new(players: fake_players)}

      it "Generate a deck to play with" do 
        expect(Uno::Deck).to receive(:generate).and_call_original

        game.start
      end

      it "Shuffle the deck" do
        new_game = Uno::Game.new(deck: fake_deck, players: fake_players)

        expect(fake_deck).to receive(:shuffle!)

        new_game.start
      end

      it "Deals 7 cards to each player" do 
        game.start
        
        game.players.each do |player, info|
          expect(info[:cards]).to be_an Array
          expect(info[:cards].length).to eq 7
        end
      end

      it "Place one card from the deck on the discard pile" do
        new_game = Uno::Game.new(deck: fake_deck, players: fake_players)
        new_game.start

        expect(new_game.discard_pile).to be_an Array
        expect(new_game.discard_pile.length).to eq 1
        expect(new_game.discard_pile.last).to be_a Uno::Card
      end

      it "Place the remaining cards from the deck into a draw pile" do 
        new_game = Uno::Game.new(deck: fake_deck, players: fake_players)
        new_game.start

        expect(new_game.draw_pile).to be_an Array
        expect(new_game.draw_pile.length).to eq 5
        expect(new_game.draw_pile.last).to be_a Uno::Card
      end

      it "Determine a play order" do 
        game.start

        expect(game.play_order).to be_an Array
        expect(game.play_order.length).to eq 2
      end

      it "Expose the current player's name" do 
        game.start

        expect(game.current_player_name).to be_a String
        expect(fake_players.keys.include?(game.current_player_name)).to be true
      end

      it "Begin in a :waiting_for_player state" do 
        game.start
        expect(game.state).to be :waiting_for_player
      end
    end

    context "When a player makes their move..." do
      let(:fake_hand) {[Uno::Card.new(:one, :red), Uno::Card.new(:zero, :blue)]}
      let(:fake_info) {{:cards => fake_hand}}
      let(:fake_players) { { "Char" => fake_info, "angelphish" => fake_info } }
      let(:game){ Uno::Game.new(players: fake_players)}

      before(:each) do 
        game.start(static_play_order: false, shuffle_deck: false)
      end

      it "Moves are only accepted from players who are in the game" do 
        expect{
          game.play("foo12", Uno::Card.new)
        }.to raise_error(Game::NotPlayersTurn)
      end

      it "A player cannot move unless it is their turn" do
        expect(game.current_player_name).to eq "Char"

        expect{
          game.play("angelphish", Uno::Card.new)
        }.to raise_error(Game::NotPlayersTurn)
      end

      it "Valid move: Playing a card matching the color of the card on top of the discard pile" do 
        expect(game.discard_pile.last.type).to eq :zero
        expect(game.discard_pile.last.color).to eq :red

        expect{
          game.play("Char", Uno::Card.new(:zero, :blue))
        }.not_to raise_error
      end

      it "Valid move: Playing a card matching the number of the card on top of the discard pile" do 
        expect(game.discard_pile.last.type).to eq :zero
        expect(game.discard_pile.last.color).to eq :red

        expect{
          game.play("Char", Uno::Card.new(:one, :red))
        }.not_to raise_error
      end

      it "Invalid move: Playing a card that does not match the color or number of the card on top of the discard pile" do 
        expect(game.discard_pile.last.type).to eq :zero
        expect(game.discard_pile.last.color).to eq :red

        expect{
          game.play("Char", Uno::Card.new(:two, :yellow))
        }.to raise_error(Game::InvalidMove)
      end
    end

    context "When a valid move is made..." do 
      context "If that was the player's last card" do 
        xit "The player wins the game"
        xit "The state should be :game_over"
      end

      context "If the player still has cards in their hand" do
       xit "The card that was just played is now on top of the discard pile"
       xit "Gameplay moves to the next player in the list"
       xit "The state should still be :waiting_for_player"
      end
    end
  end
end