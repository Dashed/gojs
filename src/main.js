// Generated by CoffeeScript 1.4.0

(function(global) {
  var _GoBoard;
  requirejs.config({
    enforceDefine: true,
    urlArgs: 'bust=' + (new Date()).getTime(),
    paths: {
      'raphael': 'libs/raphael/raphael.amd',
      'raphael.svg': 'libs/raphael/raphael.svg',
      'raphael.vml': 'libs/raphael/raphael.vml',
      'raphael.core': 'libs/raphael/raphael.core',
      'eve': 'libs/raphael/eve',
      'jquery': 'libs/jquery-1.8.3.min',
      'underscore': 'libs/underscore-min',
      'murmurhash3': 'libs/murmurhash3',
      'Board': 'Board',
      'History': 'History',
      'BoardState': 'BoardState'
    },
    shim: {
      'raphael.core': {
        deps: ['eve']
      },
      'raphael.svg': {
        deps: ['raphael.core']
      },
      'raphael.vml': {
        deps: ['raphael.core']
      },
      'raphael': {
        deps: ['raphael.core', 'raphael.svg', 'raphael.vml'],
        exports: 'Raphael'
      },
      jquery: {
        exports: '$'
      },
      underscore: {
        exports: '_'
      },
      'Board': {
        deps: ["underscore", "jquery", 'History', 'BoardState']
      },
      'History': {
        deps: ['BoardState', 'underscore', 'jquery']
      },
      'BoardState': {
        deps: ['murmurhash3']
      },
      murmurhash3: {
        exports: 'murmurhash3'
      },
      "app": {
        exports: "_GoBoard"
      }
    }
  });
  _GoBoard = (function() {

    function _GoBoard(container, container_size, board_size) {
      var get_this;
      this.container = container;
      this.container_size = container_size;
      this.board_size = board_size;
      get_this = this;
      require(["app"], function(_GoBoard) {
        return get_this.go_board = new _GoBoard(container, container_size, board_size);
      });
    }

    return _GoBoard;

  })();
  if (global.GoBoard) {
    throw new Error("GoBoard has already been defined");
  } else {
    global.GoBoard = _GoBoard;
  }
})(this || (1, eval_)("this"));
