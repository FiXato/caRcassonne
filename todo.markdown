=Todo

-----Phase 1: Tile & Meeple placement

* Add turns

  * Define players at startup
  * Switch current player at end of turn

* Add meeple placement
* Add meeple placement checks

  * Check if no-one else has claimed the road
  * Check if no-one else has claimed the meadow
  * Check if a road ends -> return the meeple and add score
  * Check if a city is completed -> return the meeple and add score

-----Phase 2: Scoring

* Add simple scoreboard (just simple counters)
* Add complex scoreboard (moving meeples over a scoring board)
* At the end of every round, count the current score or add the changed points and update scoreboard
* At end of game (re-)count all scores

  * Count left-over roads with meeples on them (only award points to the player(s) with most meeples on them)
  * Count left-over cities with meeples on them (only award points to the player(s) with most meeples on them)
  * Count meadows with meeples on them and finished cities along them (only award points to the player(s) with most meeples on them)
  

-----Phase 3: Online Multiplayer

* Allow creation of a game with a game id (and possibly password)

  * Store tileset and shuffled tiles on the server
  * Generate savestate
  * Return game id to master-client

* Allow people to 'log in' with a given game id
* At end of turn register the 'move' of the player and verify it is a valid move
* Sync savestates upon every end of turn
* Prefer a push-mechanism
* Fallback to a polling-mechanism otherwise