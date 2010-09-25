#Todo
******************************************************************************

## Phase 0: Experiment with other GUI frameworks
******************************************************************************

* Frameworks to look at:
  * Chingo (seems most interesting)
  * GGLib (has some interesting buttons/selectionboxes perhaps)
    * It feels a bit bulky.. especially with the StateObj..
    * Textboxes/Buttons are useful, but I had to monkeypatch GGLib to get things fully working..

## Phase 1: Create custom tileset

* Create graphics that will be released under Creative-Commons Non-Commercial, Share-Alike, Attribution
* Add TileSetEditor
  * Show all tiles from the default tileset
  * Add Multiplier property
  * Change property textfields to dropdowns
  * Select tiles to change their graphic and possibly properties
  * Allow adding tiles
  * Allow getting blank tiles from graphics in a directory
  * Allow saving TileSet to a packed TileSet YAML
* Create (8-bit) Carcassonne Classic TileSet with aforementioned graphics

## Phase 2: Tile & Meeple placement
******************************************************************************

* Add Mouse support
  * Right-click rotates
  * Left-click places (look at TileSetEditor for working example code)

* Add turns

  * Define players at startup
  * Switch current player at end of turn
  * Add support for players in savestates

* Add meeple placement
* Add meeple placement checks

  * Check if no-one else has claimed the road
  * Check if no-one else has claimed the meadow
  * Check if a road ends -> return the meeple and add score
  * Check if a city is completed -> return the meeple and add score

## Phase 3: Scoring
******************************************************************************

* Add simple scoreboard (just simple counters)
* Add complex scoreboard (moving meeples over a scoring board)
* At the end of every round, count the current score or add the changed points and update scoreboard
* At end of game (re-)count all scores

  * Count left-over roads with meeples on them (only award points to the player(s) with most meeples on them)
  * Count left-over cities with meeples on them (only award points to the player(s) with most meeples on them)
  * Count meadows with meeples on them and finished cities along them (only award points to the player(s) with most meeples on them)
  

## Phase 4: Online Multiplayer
******************************************************************************

* Allow creation of a game with a game id (and possibly password)

  * Store tileset and shuffled tiles on the server
  * Generate savestate
  * Return game id to master-client

* Allow people to 'log in' with a given game id
* At end of turn register the 'move' of the player and verify it is a valid move
* Sync savestates upon every end of turn
* Prefer a push-mechanism
* Fallback to a polling-mechanism otherwise