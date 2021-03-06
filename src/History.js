// Generated by CoffeeScript 1.4.0

define(function(require) {
  var $, BoardState, History, _;
  $ = require('jquery');
  _ = require('underscore');
  BoardState = require('BoardState');
  History = (function() {

    function History(starting_board_state) {
      this.starting_board_state = starting_board_state;
      this.EMPTY = 0;
      this.BLACK = 1;
      this.WHITE = 2;
      this.history = {};
      this.history_hash_order = [];
      this.add(this.starting_board_state, this.EMPTY);
    }

    History.prototype.getHashIndex = function(n) {
      var hash_index_size;
      hash_index_size = this.getNumBoardStates();
      if (n >= 0 && n <= hash_index_size - 1) {
        return this.history_hash_order[n];
      }
      return void 0;
    };

    History.prototype.getAllBoardStates = function(hash) {
      return null;
    };

    History.prototype.getBoardState = function(hash) {
      return this.history[hash];
    };

    History.prototype.getBoardStateFromIndex = function(n) {
      var hash;
      hash = this.getHashIndex(n);
      return this.history[hash];
    };

    History.prototype.add = function(raw_board_state, move_color) {
      var board_state, hash;
      board_state = new BoardState(raw_board_state, move_color);
      hash = board_state.getHash();
      this.history[hash] = board_state;
      this.history_hash_order.push(hash);
      return this;
    };

    History.prototype.getNumBoardStates = function() {
      return _.size(this.history_hash_order);
    };

    History.prototype.goBack = function(n) {
      var hash_index_size, target_hash_index;
      if (n >= 0) {
        hash_index_size = this.getNumBoardStates();
        target_hash_index = this.getHashIndex(hash_index_size - 1 - n);
        return this.getBoardState(target_hash_index);
      }
      return [][1];
    };

    History.prototype.difference = function(_old_board_state, _new_board_state) {
      var BLACK, EMPTY, WHITE, board_size, board_state_difference, new_board_state, old_board_state;
      board_state_difference = {};
      board_state_difference.stones_removed = {};
      board_state_difference.stones_removed.WHITE = [];
      board_state_difference.stones_removed.BLACK = [];
      board_state_difference.stones_added = {};
      board_state_difference.stones_added.WHITE = [];
      board_state_difference.stones_added.BLACK = [];
      old_board_state = _old_board_state.getBoardState();
      new_board_state = _new_board_state.getBoardState();
      board_size = _.size(old_board_state);
      EMPTY = this.EMPTY;
      BLACK = this.BLACK;
      WHITE = this.WHITE;
      _.each(_.range(board_size), function(i) {
        return _.each(_.range(board_size), function(j) {
          if (old_board_state[i][j] === EMPTY) {
            if (new_board_state[i][j] === BLACK) {
              board_state_difference.stones_added.BLACK.push([i, j]);
            } else if (new_board_state[i][j] === WHITE) {
              board_state_difference.stones_added.WHITE.push([i, j]);
            }
          }
          if (old_board_state[i][j] === BLACK) {
            if (new_board_state[i][j] === WHITE) {
              board_state_difference.stones_added.WHITE.push([i, j]);
              board_state_difference.stones_removed.BLACK.push([i, j]);
            } else if (new_board_state[i][j] === EMPTY) {
              board_state_difference.stones_removed.BLACK.push([i, j]);
            }
          }
          if (old_board_state[i][j] === WHITE) {
            if (new_board_state[i][j] === BLACK) {
              board_state_difference.stones_added.BLACK.push([i, j]);
              return board_state_difference.stones_removed.WHITE.push([i, j]);
            } else if (new_board_state[i][j] === EMPTY) {
              return board_state_difference.stones_removed.WHITE.push([i, j]);
            }
          }
        });
      });
      return board_state_difference;
    };

    return History;

  })();
  return History;
});
