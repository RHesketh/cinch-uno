# Important Note
Everything in this repository, *including the README that you are currently reading*, is currently under active development. This is pre-release code. As long as this message is displayed, information below may not yet be implemented in the code and the code may not be suitable for production use.

# Uno plugin
[![Gem Version](https://badge.fury.io/rb/cinch-uno.svg)](https://badge.fury.io/rb/cinch-uno)
[![License Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/UNLICENSE)

A plugin for [Cinch](https://github.com/cinchrb/cinch), the IRC bot framework for Ruby. It allows users to play the popular colorful card game in an IRC channel against other IRC users.

## Installation
First install the gem by running:

```
[sudo] gem install cinch-uno
```

or, even better, by adding it to your `Gemfile`:
```
gem 'cinch-uno' ~> "0.0.5"
```
and then running `bundle`

Then load it in your bot:

```ruby
require "cinch"
require "cinch/plugins/uno"

bot = Cinch::Bot.new do
  configure do |c|
    # add all required options here
    c.plugins.plugins = [Cinch::Plugins::Uno]
  end
end

bot.start
```

## Using the plugin
### Commands

* **uno**                               - Starts a game of Uno and waits for players to join.
* **hand**                              - The bot sends you a private message containing your current hand.
* **play** [card color] [card type]     - Plays a card.
* **skip**                              - Skips your turn and moves to the next player.
* **challenge**                         - Challenge the validity of the last player's use of Wild Draw Four.
* **accept**                            - Accept the validity of the last player's use of Wild Draw Four.

## Tests
The plugin has rspec unit and integration tests. To run them:
`rspec`

You may need to `bundle install` first.