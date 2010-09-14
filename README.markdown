# caRcassonne
******************************************************************************
caRcassonne is an open source client in Ruby striving to implement the rules 
and basic tile sets of the [Carcassonne Boardgame][1] and possibly expansion 
sets. Eventually this client might be forked into a generic tile-based 
boardgame generator/client.


## Installation Guidelines
******************************************************************************

### From Git:
`git clone git://github.com/FiXato/caRcassonne.git && cd caRcassonne && rake install`

### From RubyForge/GemCutter:
`gem install caRcassonne`


## Usage
******************************************************************************

./carcassonne                     # Starts a new game
./carcassonne 20100909004744.yaml # Starts caRcassonne and loads savestate.


### Commandline Arguments

Currently `carcassonne` supports no command-line arguments. 
In the future it might support:

* --load-savestate         => Load specified savestate
* --load-tileset <tileset> => Set tileset as active tileset
* --version                => Return the current VERSION of caRcassonne

By default only fatal errors will be output via STDOUT.
However, the following command-line arguments will in the future be available
 to set the verbosity:

* --log-errors            => Fatal and non-fatal errors.
* --warn                  => Logs warnings besides the (non-)fatal errors.
* --verbose               => Besides the --warn output, also outputs info.
* --debug                 => Most verbose form. --verbose plus debug info.

### Examples

Simplest way to run it would usually be:
`./carcassonne`


## ToDo
******************************************************************************
See the todo.markdown file.

## Notes on Patches/Pull Requests
******************************************************************************

1. Fork the project.
2. Make your feature addition or bug fix.
3. Add tests for it (even though I don't have tests myself at the moment). 
  This is important so I don't break it in a future version unintentionally.
4. Commit, but do not mess with Rakefile, version, history, or README.
  Want to have your own version? Bump version in a separate commit!
  That way I can ignore that commit when I pull.
5. Send me a pull request. Bonus points for topic branches.


## Copyright
******************************************************************************
Copyright (c) 2010 Filip H.F. "FiXato" Slagter. See LICENSE for details.


******************************************************************************
[1]: http://en.wikipedia.org/wiki/Carcassonne_%28board_game%29 (Carcassonne Boardgame Wikipedia article)