# Uno plugin
[![Gem Version](https://badge.fury.io/rb/cinch-uno.svg)](https://badge.fury.io/rb/cinch-uno)

A plugin for [Cinch](https://github.com/cinchrb/cinch), the IRC bot framework for Ruby. It allows users to play the popular colorful card game in an IRC channel against other IRC users.

## Installation
First install the gem by running:

```
[sudo] gem install cinch-uno
```

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
## Tests
The plugin has rspec tests. To run them 
`rspec`

You may need to `bundle install` first.

## Commands

```
uno - Starts a game of Uno and waits for players to join. 
```

## Options
### :fake
Ignore this, it is just an example.