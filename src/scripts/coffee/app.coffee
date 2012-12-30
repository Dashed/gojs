requirejs.config
  baseUrl: 'scripts'
  enforceDefine: true
  urlArgs: 'bust=' + (new Date()).getTime()
  paths:
    'raphael': 'libs/raphael/raphael.amd'
    'raphael.svg': 'libs/raphael/raphael.svg'
    'raphael.vml': 'libs/raphael/raphael.vml'
    'raphael.core': 'libs/raphael/raphael.core'
    'eve': 'libs/raphael/eve'
    'jquery': 'libs/jquery-1.8.3.min'
    'underscore': 'libs/underscore-min'
    'murmurhash3': 'libs/murmurhash3'
    'Board': 'Board'
    "domReady": "helper/domReady"

  shim:

    'raphael.core':
      deps: ['eve']
    'raphael.svg':
      deps: ['raphael.core']
    'raphael.vml':
      deps: ['raphael.core']
    'raphael':
      deps: ['raphael.core', 'raphael.svg', 'raphael.vml']
      exports: 'Raphael'

    jquery:
      exports: '$'

    underscore:
      exports: '_'

    'Board':
      deps: ["underscore", "jquery"]

    murmurhash3:
      exports: 'murmurhash3'



define (require) ->
  
  #This function is called once the DOM is ready.
  #It will be safe to query the DOM and manipulate
  #DOM nodes in this function.

  class _GoBoard

    VERSION: '0.1'


    constructor: (@container, @container_size, @board_size) ->

      if typeof @container != 'string' or typeof(@container_size) != 'number' or typeof @board_size != 'number'
        return

      if @container_size < 0
        return

      if @board_size > 19
        @board_size = 19

      if @board_size <= 1
        return

      @RAPH_BOARD_STATE = {} # track raphael ids

      $ = require('jquery')
      @canvas = $('#'+ @container.toString()).html('')

      # check if canvas exists
      if @canvas.length is 0
        return


      Raphael = require('raphael')
      _ = require('underscore')
      Board = require('Board')

      canvas = @canvas
      canvas.css('overflow', 'hidden').css('border', '1px solid black')

      if !$.support.inlineBlockNeedsLayout
        canvas.css('display', 'inline-block')

      # IE6/7
      # see: http://stackoverflow.com/questions/6478876/how-do-you-mix-jquery-and-ie-css-hacks
      else
        canvas.css('display', 'inline').css('zoom', '1')
      #canvas.css('display', 'block')
      

      # fundamental variables
      n = @board_size # n X n board
      cell_radius = 25
      circle_radius = 0.50 * cell_radius

      text_size = 15 #pixels
      text_buffer = text_size + cell_radius / 2 + 15
      text_movement = text_buffer/2 +5
      # cell_radius / 2 + text_size / 2 + 5
      

      canvas_length = cell_radius * (n - 1) + text_buffer * 2

      # Create canvas
      paper = Raphael(canvas[0], canvas_length, canvas_length)

      
      # coord of top left of canvas
      y = text_buffer * 1 # top-left x
      x = text_buffer # top-left y
      
      # construct the board
      board_outline = paper.rect(x, y, cell_radius * (n - 1), cell_radius * (n - 1)).attr('stroke-width', 2)
      paper.rect(x, y, cell_radius * (n - 1), cell_radius * (n - 1)).attr 'stroke-width', 1      

      # Star point markers (handicap markers)
      # See: http://senseis.xmp.net/?Hoshi
      do () ->
        generate_star = (_x, _y) ->
          handicap = paper.circle(x + cell_radius * _x, y + cell_radius * _y, 0.20 * circle_radius)
          handicap.attr 'fill', '#000'

        if n is 19
          generate_star 3, 3
          generate_star 9, 3
          generate_star 15, 3
          generate_star 3, 9
          generate_star 9, 9
          generate_star 15, 9
          generate_star 3, 15
          generate_star 9, 15
          generate_star 15, 15
        else if n is 13
          generate_star 3, 3
          generate_star 9, 3
          generate_star 6, 6
          generate_star 3, 9
          generate_star 9, 9
        else if n is 9
          generate_star 2, 2
          generate_star 6, 2
          generate_star 4, 4
          generate_star 2, 6
          generate_star 6, 6


      # draw lines and coordinate labels
      stone_click_detect = paper.set()
      _.each _.range(n), (index) ->

        i = index

        # construct lines
        # ignore outlines
        if index < n - 1 
          
          line_vert = paper.path('M' + (x + cell_radius * (i + 1)) + ',' + (y + cell_radius * (n - 1)) + 'V' + (y))
          line_horiz = paper.path('M' + x + ',' + (y + cell_radius * (i + 1)) + 'H' + (x + cell_radius * (n - 1)))

        # Alphabet
        letter = String.fromCharCode(65 + index)
        paper.text(x + cell_radius * (index), y + cell_radius * (n - 1) + text_movement, letter).attr 'font-size', text_size
        paper.text(x + cell_radius * (index), y - text_movement, letter).attr 'font-size', text_size

        # Numbers
        paper.text(x - text_movement, y + cell_radius * (n - 1 - index), index+1).attr 'font-size', text_size
        paper.text(x + cell_radius * (n - 1) + text_movement, y + cell_radius * (n - 1 - index), index+1).attr 'font-size', text_size

        # Place click detectors
        _.each _.range(n), (j, index) ->
          clicker = paper.rect(x - cell_radius / 2 + cell_radius * i, y - cell_radius / 2 + cell_radius * j, cell_radius, cell_radius)
          clicker.attr 'fill', '#fff'
          clicker.attr 'fill-opacity', 0
          clicker.attr 'opacity', 0
          clicker.attr 'stroke-width', 0
          clicker.attr 'stroke', '#fff'
          clicker.attr 'stroke-opacity', 0
          clicker.data 'coord', [i, j]
          stone_click_detect.push clicker

      # Put stones on board if user has clicked
      ###
      _.each _.range(n), (i, index) ->
        _.each _.range(n), (j, index) ->
          clicker = paper.rect(x - cell_radius / 2 + cell_radius * i, y - cell_radius / 2 + cell_radius * j, cell_radius, cell_radius)
          clicker.attr 'fill', '#fff'
          clicker.attr 'fill-opacity', 0
          clicker.attr 'opacity', 0
          clicker.attr 'stroke-width', 0
          clicker.attr 'stroke', '#fff'
          clicker.attr 'stroke-opacity', 0
          clicker.data 'coord', [i, j]
          stone_click_detect.push clicker
      ###

      

      # Populate with stones

      # tracks move made
      track_stone_pointer = null
      track_stone = (i, j) ->
        _x = x + cell_radius * i
        _y = y + cell_radius * j
        track_stone_pointer.remove()  if track_stone_pointer?
        track_stone_pointer = paper.circle(_x, _y, circle_radius / 2)
        track_stone_pointer.attr 'stroke', 'red'
        track_stone_pointer.attr 'stroke-width', '2'

      white_stone = (i, j) ->
        _x = x + cell_radius * i
        _y = y + cell_radius * j
        
        stone_bg = paper.circle(_x, _y, circle_radius)
        stone_bg.attr 'fill', '#fff'
        stone_bg.attr 'stroke-width', '0'

        stone_fg = paper.circle(_x, _y, circle_radius)
        stone_fg.attr 'fill', 'r(0.75,0.75)#fff-#A0A0A0'
        stone_fg.attr 'fill-opacity', 1
        stone_fg.attr 'stroke-opacity', 0.3
        stone_fg.attr 'stroke-width', '1.1'

        track_stone(i,j)

        ###
        # triangle
        circle_radius_t = circle_radius*0.85
        a = (circle_radius_t*3)/Math.sqrt(3)
        height = Math.sqrt(3)*a/2
        #C = _x, circle_radius
        #B = _x + a/2, _y - (height - circle_radius)
        #A = _x - a/2, _y - (height - circle_radius)
        A = [_x - a/2, _y+(height - circle_radius_t)]
        B = [_x + a/2, _y+(height - circle_radius_t)]
        C = [_x, _y-circle_radius_t]
        
        # AC
        lol = paper.path('M'+A[0]+' '+A[1]+'L'+C[0]+' '+C[1]).toFront()
        
        # CB

        paper.path('M'+C[0]+' '+C[1]+'L'+B[0]+' '+B[1]).toFront()

        # BA
        paper.path('M'+B[0]+' '+B[1]+'L'+A[0]+' '+A[1]).toFront()

        ###
        group = []
        group.push stone_bg.id
        group.push stone_fg.id
        return group

        

      black_stone = (i, j) ->
        _x = x + cell_radius * i
        _y = y + cell_radius * j

        stone_bg = paper.circle(_x, _y, circle_radius)
        stone_bg.attr 'fill', '#fff'
        stone_bg.attr 'stroke-width', '0'

        stone_fg = paper.circle(_x, _y, circle_radius)
        stone_fg.attr 'fill-opacity', 0.9
        stone_fg.attr 'fill', 'r(0.75,0.75)#A0A0A0-#000'
        stone_fg.attr 'stroke-opacity', 0.3
        stone_fg.attr 'stroke-width', '1.2'

        track_stone(i,j)

        group = []
        group.push stone_bg.id
        group.push stone_fg.id
        return group
      


      get_this = this
      remove_stone = (coord) ->
        _.each get_this.RAPH_BOARD_STATE[coord], (id) ->
          paper.getById(id).remove()
        return

      
      # Replicate board in memory
      # this is a singleton instance
      virtual_board = new Board(n)

      # Click event
      get_this = this
      stone_click_detect.click (e) ->

        coord = @data('coord')

        move_results = virtual_board.move(coord)

        # remove_stones
        _.each move_results.dead, (dead_stone) ->
          remove_stone(dead_stone) 
         

        switch move_results.color
          when virtual_board.BLACK

            get_this.RAPH_BOARD_STATE[coord] = black_stone(move_results.x, move_results.y)
            
          when virtual_board.WHITE

            get_this.RAPH_BOARD_STATE[coord] = white_stone(move_results.x, move_results.y)
            
          else
            # do nothing

        # move detect element to front to be clicked again
        this.toFront()
        return

  
      


      

      paper.safari()
      paper.renderfix()




      # Replaced by http://www.shapevent.com/scaleraphael/
      ###
      length = @container_size
      canvas.height(length)
      canvas.width(length)

      viewbox_length = canvas_length*canvas_length/canvas.width()
      paper.setViewBox(0, 0, viewbox_length*2, viewbox_length*2, true)
      paper.setSize(canvas_length*2,canvas_length*2)
      ###
      
      length = this.container_size;
      canvas.height(length).width(length);
      #viewbox_length = canvas_length * canvas_length / canvas.width();
      paper.setViewBox(0, 0, canvas_length, canvas_length, false);
      paper.setSize(length, length);

      # Fill board with all stones 
      ###
      _.each _.range(0, n, 2), (i, index) ->
        _.each _.range(0, n, 2), (j, index) ->
          white_stone i, j


      _.each _.range(1, n, 2), (i, index) ->
        _.each _.range(1, n, 2), (j, index) ->
          white_stone i, j


      _.each _.range(1, n, 2), (i, index) ->
        _.each _.range(0, n, 2), (j, index) ->
          black_stone i, j


      _.each _.range(0, n, 2), (i, index) ->
        _.each _.range(1, n, 2), (j, index) ->
          black_stone i, j
      ###

      return @

  return _GoBoard

