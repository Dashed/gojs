// Generated by CoffeeScript 1.6.3
var requirejs;

requirejs = require('requirejs');

requirejs(['config', 'main'], function(config, goban) {
  var lol;
  lol = new goban(10);
  return console.log(lol);
});
