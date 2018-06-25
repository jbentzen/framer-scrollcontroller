# Name: ScrollController
# Version: 1.0.1
# Author: Jesper Bentzen
# Website: http://jesperbentzen.com
# Github: https://github.com/jbentzen/framer-scrollcontroller
# Description: ScrollController is a Framer module that helps you to animate, pin and trigger events based on scroll position.
# Usage: {ScrollController} = require 'ScrollController'


# Class: Controller
class Controller extends Layer
  constructor: (options={}) ->
    super _.defaults options,
      name: options.name ? "."
      parent: options.source
      width: 0
      height: 0
      backgroundColor: null
    @_source = options.source
    @_direction = options.direction ? "vertical"
    @_throttle = options.throttle ? 0
    @_enabled = options.enabled ? true
    Object.defineProperty @, "source",
      get: -> return @_source
      set: (value) -> throw new Error "source is read only"
    Object.defineProperty @, "direction",
        get: -> return @_direction
        set: (value) -> throw new Error "direction is read only"
    Object.defineProperty @, "throttle",
      get: -> return @_throttle
      set: (value) ->
        if typeof value is "number"
          @_throttle = value
          @_initialise()
        else
          throw new Error "throttle must be a number larger than or equal 0"
    Object.defineProperty @, "enabled",
      get: -> return @_enabled
      set: (value) ->
        if typeof value is "boolean"
          @_enabled = value
          @refresh()
        else
          throw new Error "enabled must be a boolean either true or false"
    Object.defineProperty @, "scenes",
      get: -> return @_scenes
      set: (value) -> throw new Error "scenes is read only"
    @_scenes = []
    @_initialise()

  _initialise: =>
    @_source.off "change:size", @_onResize
    @_source.off "move", @_onMove
    @_source.on "change:size", Utils.throttle @_throttle, @_onResize
    @_source.on "move", Utils.throttle @_throttle, @_onMove
    @refresh()

  _onResize: =>
    @update()

  _onMove: =>
    @refresh()

  update: ->
    if @_enabled is true
      scene.update() for scene in @_scenes

  refresh: ->
    if @_enabled is true
      scene.refresh() for scene in @_scenes

  scrollTo: (options={}) ->
    _element = options.element
    _offset = options.offset ? 0
    _progress = options.progress ? 0
    _animate = options.animate ? undefined
    _options = options.options ? undefined
    if @_direction is "vertical"
      _yPos = 0
      _yPos += _element._start+_element._scrollOffset if _element instanceof Scene
      _yPos += _element.convertPointToLayer({x:0,y:0}, @_source.content).y+@_source.contentInset.top if _element instanceof Layer and _element !instanceof Scene
      _yPos += _progress*_element._duration if typeof _progress is "number" and _element instanceof Scene
      _yPos += _offset if typeof _offset is "number"
      @_source.scrollToPoint(y:_yPos, _animate, _options)
    else if @_direction is "horizontal"
      _xPos = 0
      _xPos += _element._start+_element._scrollOffset if _element instanceof Scene
      _xPos += _element.convertPointToLayer({x:0,y:0}, @_source.content).x+@_source.contentInset.left if _element instanceof Layer and _element !instanceof Scene
      _xPos += _progress*_element._duration if typeof _progress is "number" and _element instanceof Scene
      _xPos += _offset if typeof _offset is "number"
      _yPos = @_source.scrollY
      @_source.scrollToPoint(x:_xPos, _animate, _options)

  addScene: (options={}) ->
    new Scene
      source: @_source
      controller: @
      triggerLayer: options.triggerLayer
      needle: options.needle
      offset: options.offset
      duration: options.duration
      reverse: options.reverse
      enabled: options.enabled
      guide: options.guide
      name: options.name
      guideNeedleColor: options.guideNeedleColor
      guideStartColor: options.guideStartColor
      guideEndColor: options.guideEndColor
      guideIndent: options.guideIndent

  removeScene: (scene, reset) ->
    @_scenes.splice(@_scenes.indexOf(scene), 1)
    scene._removeGuide(scene._guides[0]) for guide in scene._guides
    scene.removeTween(scene._tweens[0], reset) for tween in scene._tweens
    scene.removePin(scene._pins[0], reset) for pin in scene._pins
    scene.destroy()

  remove: (reset) =>
    @_source.off "change:size", @_onResize
    @_source.off "move", @_onMove
    @removeScene(@_scenes[0], reset) for scene in @_scenes
    @destroy()


# Class: Scene
class Scene extends Layer
  constructor: (options={}) ->
    super _.defaults options,
      name: options.name ? "."
      parent: options.controller
      width: 0
      height: 0
      backgroundColor: null
    @_controller = options.controller
    @_source = options.source
    @_triggerLayer = options.triggerLayer ? undefined
    @_needle = options.needle ? 0.5
    @_offset = options.offset ? 0
    @_duration = options.duration ? 0
    @_reverse = options.reverse ? true
    @_enabled = options.enabled ? true
    @_guide = options.guide ? false
    @_guideNeedleColor = options.guideNeedleColor ? "#0066FF"
    @_guideStartColor = options.guideStartColor ? "#009933"
    @_guideEndColor = options.guideEndColor ? "#FF3333"
    @_guideIndent = options.guideIndent ? 20
    Object.defineProperty @, "source",
      get: -> return @_source
      set: (value) -> throw new Error "source is read only"
    Object.defineProperty @, "controller",
      get: -> return @_controller
      set: (value) -> throw new Error "controller is read only"
    Object.defineProperty @, "triggerLayer",
      get: -> return @_triggerLayer
      set: (value) ->
        if value instanceof Layer
          @_triggerLayer = value
          @_initialise()
          @update()
          @emit "changeValue", {property:"triggerLayer", value:value}
          @emit "shift", {reason:"triggerLayer"}
        else
          throw new Error "triggerLayer cannot be set"
    Object.defineProperty @, "needle",
      get: -> return @_needle
      set: (value) ->
        if typeof value is "number" and value >= 0 and value <= 1
          @_needle = value
          @update()
          @emit "changeValue", {property:"needle", value:value}
          @emit "shift", {reason:"needle"}
        else
          throw new Error "duration must be a number between 0 and 1"
    Object.defineProperty @, "offset",
      get: -> return @_offset
      set: (value) ->
        if typeof value is "number"
          @_offset = value
          @update()
          @emit "changeValue", {property:"offset", value:value}
          @emit "shift", {reason:"offset"}
        else
          throw new Error "offset must be a number"
    Object.defineProperty @, "duration",
      get: -> return @_duration
      set: (value) ->
        if typeof value is "number"
          @_duration = value
          @update()
          @emit "changeValue", {property:"duration", value:value}
          @emit "shift", {reason:"duration"}
        else
          throw new Error "duration must be a number larger than or equal 0"
    Object.defineProperty @, "reverse",
      get: -> return @_reverse
      set: (value) ->
        if typeof value is "boolean"
          @_reverse = value
          @refresh()
          @emit "changeValue", {property:"reverse", value:value}
        else
          throw new Error "reverse must be a boolean either true or false"
    Object.defineProperty @, "enabled",
      get: -> return @_enabled
      set: (value) ->
        if typeof value is "boolean"
          @_enabled = value
          @refresh()
          @emit "changeValue", {property:"enabled", value:value}
        else
          throw new Error "enabled must be a boolean either true or false"
    Object.defineProperty @, "guide",
      get: -> return @_guide
      set: (value) -> throw new Error "guide is read only"
    Object.defineProperty @, "progress",
      get: -> return @_progress
      set: (value) -> throw new Error "progress cannot be set"
    Object.defineProperty @, "start",
      get: -> return @_start
      set: (value) -> throw new Error "sceneStart cannot be set"
    Object.defineProperty @, "end",
      get: -> return @_end
      set: (value) -> throw new Error "sceneEnd cannot be set"
    Object.defineProperty @, "needlePos",
      get: -> return @_needlePos
      set: (value) -> throw new Error "needlePos cannot be set"
    Object.defineProperty @, "scrollOffset",
      get: -> return @_scrollOffset
      set: (value) -> throw new Error "scrollOffset cannot be set"
    Object.defineProperty @, "offsetStart",
      get: -> return @_offsetStart
      set: (value) -> throw new Error "offsetStart cannot be set"
    Object.defineProperty @, "offsetEnd",
      get: -> return @_offsetEnd
      set: (value) -> throw new Error "offsetEnd cannot be set"
    Object.defineProperty @, "state",
      get: -> return @_state
      set: (value) -> throw new Error "state cannot be set"
    Object.defineProperty @, "tweens",
      get: -> return @_tweens
      set: (value) -> throw new Error "tweens cannot be set"
    Object.defineProperty @, "pins",
      get: -> return @_pins
      set: (value) -> throw new Error "pins cannot be set"
    @_controller._scenes.push @
    @_guides = []
    @_tweens = []
    @_pins = []
    @_initialise()
    @_calibrate()
    @_addGuide() if @_guide is true

  _initialise: ->
    if @_triggerLayer
      if @_controller._direction is "vertical"
        @_triggerLayerContentPos = @_triggerLayer.convertPointToLayer({x:0,y:0}, @_source.content).y
      else if @_controller._direction is "horizontal"
        @_triggerLayerContentPos = @_triggerLayer.convertPointToLayer({x:0,y:0}, @_source.content).x
    else
      @_triggerLayerContentPos = 0

  _calibrate: ->
    if @_controller._direction is "vertical"
      _scrollPos = @_source.scrollY
      _contentInset = @_source.contentInset.top
      _contentLength = @_source.height
    else if @_controller._direction is "horizontal"
      _scrollPos = @_source.scrollX
      _contentInset = @_source.contentInset.left
      _contentLength = @_source.width
    @_start = @_triggerLayerContentPos+@_offset
    @_end = @_start+@_duration
    @_needlePos = Utils.round(@_needle*_contentLength)
    @_scrollOffset = Utils.round(_contentInset-@_needlePos)
    @_offsetStart = @_start+@_scrollOffset
    @_offsetEnd = @_offsetStart+@_duration
    @_offsetScrollPos = _scrollPos-@_scrollOffset
    @refresh()

  _addGuide: ->
    new Guide
      source: @_source
      controller: @_controller
      scene: @

  _removeGuide: (guide) ->
    guide._container.destroy()
    guide.destroy()

  update: ->
    if @_enabled is true
      _scrollPos = @_source.scrollY if @_controller._direction is "vertical"
      _scrollPos = @_source.scrollX if @_controller._direction is "horizontal"
      @_calibrate()
      @emit "update", {start:@_start, end:@_end, scrollPos:_scrollPos}
      guide.update() for guide in @_guides
      tween.update() for tween in @_tweens
      pin.update() for pin in @_pins

  refresh: ->
    if @_enabled is true
      if @_controller._direction is "vertical"
        _scrollPos = @_source.scrollY
        _contentInset = @_source.contentInset.top
      else if @_controller._direction is "horizontal"
        _scrollPos = @_source.scrollX
        _contentInset = @_source.contentInset.left
      _scrollDir = @_source.direction
      @_offsetScrollPos = _scrollPos-@_scrollOffset
      @_scrollDist = @_offsetScrollPos if !@_scrollDist
      @_isProgressing = @_offsetScrollPos > @_scrollDist
      @_scrollDist = @_offsetScrollPos if @_isProgressing
      if @_duration isnt 0
        if _scrollPos < @_offsetStart
          if @_state isnt "before"
            @_progress = 0
            @emit "progress", {progress:@_progress, state:"before", scrollDir:_scrollDir} if @_state is "during" or @_state is "after"
            @emit "start", {progress:@_progress, state:"before", scrollDir:_scrollDir} if @_state is "during"
            @emit "leave", {progress:@_progress, state:"before", scrollDir:_scrollDir} if @_state is "during"
            @_state = "before"
        else if _scrollPos >= @_offsetStart and _scrollPos < @_offsetEnd
          @_progress = 1-(@_offsetEnd-_scrollPos)/@_duration
          if @_state isnt "during"
            @emit "enter", {progress:@_progress, state:"during", scrollDir:_scrollDir} if @_state is "before" or @_state is "after"
            @emit "start", {progress:@_progress, state:"during", scrollDir:_scrollDir} if @_state is "before"
            @emit "end", {progress:@_progress, state:"during", scrollDir:_scrollDir} if @_state is "after"
            @_state = "during"
          @emit "progress", {progress:@_progress, state:"during", scrollDir:_scrollDir}
        else if _scrollPos >= @_offsetEnd
          if @_state isnt "after"
            @_progress = 1
            @emit "progress", {progress:@_progress, state:"after", scrollDir:_scrollDir} if @_state is "during" or @_state is "before"
            @emit "end", {progress:@_progress, state:"after", scrollDir:_scrollDir} if @_state is "during"
            @emit "leave", {progress:@_progress, state:"after", scrollDir:_scrollDir} if @_state is "during"
            @_state = "after"
      else if @_duration is 0
        if _scrollPos < @_offsetStart
          if @_state isnt "before"
            @_progress = 0
            @emit "progress", {progress:@_progress, state:"before", scrollDir:_scrollDir} if @_state is "during"
            @emit "start", {progress:@_progress, state:"before", scrollDir:_scrollDir} if @_state is "during"
            @emit "leave", {progress:@_progress, state:"before", scrollDir:_scrollDir} if @_state is "during"
            @_state = "before"
        else if _scrollPos >= @_offsetEnd
          if @_state isnt "during"
            @_progress = 1
            @emit "enter", {progress:@_progress, state:"during", scrollDir:_scrollDir} if @_state is "before"
            @emit "start", {progress:@_progress, state:"during", scrollDir:_scrollDir} if @_state is "before"
            @emit "progress", {progress:@_progress, state:"during", scrollDir:_scrollDir} if @_state is "before"
            @_state = "during"
      guide.refresh() for guide in @_guides
      tween.refresh() for tween in @_tweens
      pin.refresh() for pin in @_pins

  remove: (reset) ->
    @_controller.removeScene(@, reset)

  trigger: (options={}) ->
    _name = options.name
    _event = options.event ? undefined
    @emit _name, _event

  addTween: (options={}) ->
    new Tween
      controller: @_controller
      source: @_source
      scene: @
      name: options.name
      layer: options.layer
      from: options.from
      to: options.to
      options: options.options
      init: options.init
      enabled: options.enabled

  removeTween: (tween, reset) ->
    @off "enter", tween._onEnter
    @off "leave", tween._onLeave
    @off "progress", tween._onProgress
    @_tweens.splice(@_tweens.indexOf(tween), 1)
    if reset is true
      tween._tweenLayer.props = tween._initTweenLayerProps
    tween.destroy()

  addPin: (options={}) ->
    new Pin
      controller: @_controller
      source: @_source
      scene: @
      name: options.name
      layer: options.layer
      enabled: options.enabled

  removePin: (pin, reset) ->
    @off "enter", pin._onEnter
    @off "leave", pin._onLeave
    @_pins.splice(@_pins.indexOf(pin), 1)
    pin._layer.parent = pin._pinLayer.parent
    pin._layer.index = pin._pinLayer.index
    if reset isnt true
      pin._layer.y += pin._pinLayer.y
    pin._pinLayer.destroy()
    pin.destroy()

  onChangeValue: (cb) -> @on "changeValue", cb
  onShift: (cb) -> @on "shift", cb
  onUpdate: (cb) -> @on "update", cb
  onEnter: (cb) -> @on "enter", cb
  onStart: (cb) -> @on "start", cb
  onProgress: (cb) -> @on "progress", cb
  onEnd: (cb) -> @on "end", cb
  onLeave: (cb) -> @on "leave", cb


# Class: Tween
class Tween extends Layer
  constructor: (options={}) ->
    super _.defaults options,
      name: options.name ? "."
      parent: options.scene
      width: 0
      height: 0
      backgroundColor: null
    @_controller = options.controller
    @_source = options.source
    @_scene = options.scene
    @_layer = options.layer ? undefined
    @_from = options.from ? undefined
    @_to = options.to ? undefined
    @_options = options.options ? undefined
    @_init = options.init ? true
    @_enabled = options.enabled ? true
    Object.defineProperty @, "source",
      get: -> return @_source
      set: (value) -> throw new Error "source is read only"
    Object.defineProperty @, "controller",
      get: -> return @_controller
      set: (value) -> throw new Error "controller is read only"
    Object.defineProperty @, "scene",
      get: -> return @_scene
      set: (value) -> throw new Error "scene is read only"
    Object.defineProperty @, "layer",
      get: -> return @_layer
      set: (value) -> throw new Error "layer is read only"
    Object.defineProperty @, "from",
      get: -> return @_from
      set: (value) -> throw new Error "from is read only"
    Object.defineProperty @, "to",
      get: -> return @_to
      set: (value) -> throw new Error "to is read only"
    Object.defineProperty @, "options",
      get: -> return @_options
      set: (value) -> throw new Error "options is read only"
    Object.defineProperty @, "init",
      get: -> return @_init
      set: (value) -> throw new Error "init is read only"
    Object.defineProperty @, "enabled",
      get: -> return @_enabled
      set: (value) ->
        if typeof value is "boolean"
          @_enabled = value
          @_scene.refresh()
        else
          throw new Error "enabled must be a boolean either true or false"
    @_scene._tweens.push @
    @_createTween()
    @_initialise()

  _createTween: ->
    @_tweenLayer = if @_layer then @_layer else @_scene._triggerLayer
    @_initTweenLayerProps = @_tweenLayer.props if !@_initTweenLayerProps
    if @_from
      _tweenProperties = @_from
      _tweenOptions = @_options
      @_tweenReverse = new Animation @_tweenLayer, {properties: _tweenProperties, options: _tweenOptions}
      @_tween = @_tweenReverse.reverse() if !@_to
    if @_to
      _tweenProperties = @_to
      _tweenOptions = @_options
      @_tween = new Animation @_tweenLayer, {properties: _tweenProperties, options: _tweenOptions}
      @_tweenReverse = @_tween.reverse() if !@_from

  _initialise: ->
    if @_init is true
      if @_scene.state is "before"
        @_tweenReverse.start()
        @_tweenReverse.finish()
      else if @_scene.state is "during"
        @_tween.start() if @_scene._duration is 0
        @_tween.finish() if @_scene._duration is 0
      else if @_scene.state is "after"
        @_tween.start() if @_scene._duration > 0
        @_tween.finish() if @_scene._duration > 0
      @_onProgress()
    @_scene.on "enter", @_onEnter
    @_scene.on "leave", @_onLeave
    @_scene.on "progress", @_onProgress

  _onEnter: =>
    if @_enabled is true
      if @_scene._duration is 0
        @_tween.start()

  _onLeave: =>
    if @_enabled is true
      if @_scene._duration is 0
        @_tweenReverse.start() if @_scene._reverse is true

  _onProgress: =>
    if @_enabled is true
      if @_scene._duration > 0
        if @_scene._reverse is true or @_scene._reverse is false and @_scene._isProgressing is true
          for property of @_tweenReverse.properties
            _from = @_tweenReverse.properties["#{property}"]
            _to = @_tween.properties["#{property}"]
            if typeof _from is "number" and typeof _to is "number"
              @_tween.layer["#{property}"] = Utils.modulate(@_scene.progress,[0,1],[_from, _to], true)
            else if Color.isColor(_from) and Color.isColor(_to)
              @_tween.layer["#{property}"] = Color.mix(_from, _to, @_scene.progress, true, @_tween.options.colorModel)

  update: ->
    if @_enabled is true
      return

  refresh: ->
    if @_enabled is true
      return

  remove: (reset) ->
    @_scene.removeTween(@, reset)


# Class: Pin
class Pin extends Layer
  constructor: (options={}) ->
    super _.defaults options,
      name: options.name ? "."
      parent: options.scene
      width: 0
      height: 0
      backgroundColor: null
    @_source = options.source
    @_controller = options.controller
    @_scene = options.scene
    @_layer = options.layer ? @_scene._triggerLayer
    @_enabled = options.enabled ? true
    Object.defineProperty @, "source",
      get: -> return @_source
      set: (value) -> throw new Error "source is read only"
    Object.defineProperty @, "controller",
      get: -> return @_controller
      set: (value) -> throw new Error "controller is read only"
    Object.defineProperty @, "scene",
      get: -> return @_scene
      set: (value) -> throw new Error "scene is read only"
    Object.defineProperty @, "layer",
      get: -> return @_layer
      set: (value) -> throw new Error "layer is read only"
    Object.defineProperty @, "enabled",
      get: -> return @_enabled
      set: (value) ->
        if typeof value is "boolean"
          @_enabled = value
          @_scene.refresh()
        else
          throw new Error "enabled must be a boolean either true or false"
    Object.defineProperty @, "state",
      get: -> return @_state
      set: (value) -> throw new Error "state is read only"
    @_scene._pins.push @
    @_createPin()
    @_initialise()

  _createPin: ->
    @_pinLayer = new Layer
      name: if @name is "." then "pin" else "#{@name}"
      parent: @_layer.parent
      index: @_layer.index
      width: 0
      height: 0
      backgroundColor: null
    @_layer.props =
      parent: @_pinLayer

  _initialise: ->
    @_state = if @_scene.state is "during" then "pinned" else "unpinned"
    @_scene.on "enter", @_onEnter
    @_scene.on "leave", @_onLeave
    @refresh()

  _onEnter: =>
    if @_enabled is true
      if @_state isnt "pinned"
        @_state = "pinned"

  _onLeave: =>
    if @_enabled is true
      if @_state isnt "unpinned"
        @_state = "unpinned"

  update: ->
    if @_enabled is true
      return

  refresh: ->
    if @_enabled is true
      if @_scene._reverse is true or @_scene._reverse is false and @_scene._isProgressing is true
        _scrollPos = @_source.scrollY if @_controller._direction is "vertical"
        _scrollPos = @_source.scrollX if @_controller._direction is "horizontal"
        _offsetStart = @_scene._offsetStart
        _offsetEnd = @_scene._offsetEnd
        _duration = @_scene._duration
        if _scrollPos < _offsetStart
          @_pinLayer.y = 0 if @_controller._direction is "vertical"
          @_pinLayer.x = 0 if @_controller._direction is "horizontal"
        else if _scrollPos >= _offsetStart and _scrollPos < @_scene._offsetEnd
          @_pinLayer.y = _scrollPos-_offsetStart if @_controller._direction is "vertical"
          @_pinLayer.x = _scrollPos-_offsetStart if @_controller._direction is "horizontal"
        else if _scrollPos >= _offsetEnd
          if @_controller._direction is "vertical"
            @_pinLayer.y = _duration if _duration isnt 0
            @_pinLayer.y = _scrollPos-_offsetStart if _duration is 0
          else if @_controller._direction is "horizontal"
            @_pinLayer.x = _duration if _duration isnt 0
            @_pinLayer.x = _scrollPos-_offsetStart if _duration is 0

  remove: (reset) ->
    @_scene.removePin(@, reset)


# Class: Guide
class Guide extends Layer
  constructor: (options={}) ->
    super _.defaults options,
      name: "."
      parent: options.scene
      width: 0
      height: 0
      backgroundColor: null
    @_controller = options.controller
    @_source = options.source
    @_scene = options.scene
    @_scene._guides.push @
    @_createGuide()

  _createGuide: ->
    @_needleColor = @_scene._guideNeedleColor
    @_startColor = @_scene._guideStartColor
    @_endColor = @_scene._guideEndColor
    @_indent = @_scene._guideIndent
    @_fontSize = 10
    @_fontWeight = 700
    @_name = if @_scene.name is "." then "" else "#{@_scene.name}: "
    _needleText = "#{@_name}#{Utils.round(@_scene._offsetScrollPos)}"
    _startText = "#{@_name}#{Utils.round(@_scene._start)}"
    _endText = "#{@_name}#{Utils.round(@_scene._end)}"
    if @_controller._direction is "vertical"
      @_lineWidth = 20
      @_lineHeight = 1
      _containerX = @_source.scrollX-@_source.contentInset.left
      _needleX = @_source.width-@_indent
      _startX = @_source.width-@_lineWidth-@_indent
      _endX = @_source.width-@_lineWidth-@_indent
      _containerY = 0
      _needleY = Utils.round(@_scene._needlePos)
      _startY = Utils.round(@_scene._start)
      _endY = Utils.round(@_scene._end)
    else if @_controller._direction is "horizontal"
      @_lineWidth = 1
      @_lineHeight = 20
      _containerX = 0
      _needleX = Utils.round(@_scene._needlePos)
      _startX = Utils.round(@_scene._start)
      _endX = Utils.round(@_scene._end)
      _containerY = @_source.scrollY-@_source.contentInset.top
      _needleY = @_source.height-@_indent
      _startY = @_source.height-@_lineHeight-@_indent
      _endY = @_source.height-@_lineHeight-@_indent

    _createContainer = (parent, x, y) =>
      container = new Layer
        name: "."
        parent: parent
        width: 0
        height: 0
        x: x
        y: y
        backgroundColor: null
      return container

    _createMarker = (name, parent, x, y, indent, text, color) =>
      marker = {}
      if @_controller._direction is "vertical"
        _lineX = x-@_lineWidth
        _lineY = y
        _labelX = x
        _labelY = y+@_fontSize
        _labelRotation = 90
      else if @_controller._direction is "horizontal"
        _lineX = x
        _lineY = y-@_lineHeight
        _labelX = x+@_fontSize
        _labelY = y-@_fontSize
      marker.line = new Layer
        name: name
        parent: parent
        width: @_lineWidth
        height:@_lineHeight
        x: _lineX
        y: _lineY
        backgroundColor: color
      marker.label = new TextLayer
        name: "#{name}Label"
        parent: parent
        originX: 0
        originY: 0
        x: _labelX
        y: _labelY
        rotation: _labelRotation
        text: text
        fontSize: @_fontSize
        fontWeight: @_fontWeight
        color: color
      return marker

    @_container = _createContainer(@_source.content, _containerX, _containerY)
    @_needleMarker = _createMarker("needle", @, _needleX, _needleY, @_indent, _needleText, @_needleColor)
    @_startMarker = _createMarker("start", @_container, _startX, _startY, @_indent, _startText, @_startColor)
    @_endMarker = _createMarker("end", @_container, _endX, _endY, @_indent, _endText, @_endColor)
    @_endMarker.line.visible = false if @_scene._duration is 0
    @_endMarker.label.visible = false if @_scene._duration is 0

  _updateGuide: ->
    _needleText = "#{@_name}#{Utils.round(@_scene._offsetScrollPos)}"
    _startText = "#{@_name}#{Utils.round(@_scene._start)}"
    _endText = "#{@_name}#{Utils.round(@_scene._end)}"
    if @_controller._direction is "vertical"
      _containerX = @_source.scrollX-@_source.contentInset.left
      _needleX = @_source.width-@_indent
      _startX = @_source.width-@_lineWidth-@_indent
      _endX = @_source.width-@_lineWidth-@_indent
      _containerY = 0
      _needleY = Utils.round(@_scene._needlePos)
      _startY = Utils.round(@_scene._start)
      _endY = Utils.round(@_scene._end)
    else if @_controller._direction is "horizontal"
      _containerX = 0
      _needleX = Utils.round(@_scene._needlePos)
      _startX = Utils.round(@_scene._start)
      _endX = Utils.round(@_scene._end)
      _containerY = @_source.scrollY-@_source.contentInset.top
      _needleY = @_source.height-@_indent
      _startY = @_source.height-@_lineHeight-@_indent
      _endY = @_source.height-@_lineHeight-@_indent

    _updateContainer = (container, x, y) =>
      container.props =
        x: x
        y: y

    _updateMarker = (marker, x, y, text) =>
      if @_controller._direction is "vertical"
        _lineX = x-@_lineWidth
        _lineY = y
        _labelX = x
        _labelY = y+@_fontSize
      else if @_controller._direction is "horizontal"
        _lineX = x
        _lineY = y-@_lineHeight
        _labelX = x+@_fontSize
        _labelY = y-@_fontSize
      marker.line.props =
        x: _lineX
        y: _lineY
      marker.label.props =
        x: _labelX
        y: _labelY
        text: text

    _updateContainer(@_container, _containerX, _containerY)
    _updateMarker(@_needleMarker, _needleX, _needleY, _needleText)
    _updateMarker(@_startMarker, _startX, _startY, _startText)
    _updateMarker(@_endMarker, _endX, _endY, _endText)

  _refreshGuide: ->
    _needleText = "#{@_name}#{Utils.round(@_scene._offsetScrollPos)}"
    if @_controller._direction is "vertical"
      _containerX = @_source.scrollX-@_source.contentInset.left
      _containerY = 0
    else if @_controller._direction is "horizontal"
      _containerX = 0
      _containerY = @_source.scrollY-@_source.contentInset.top

    _refreshMarker = (marker, text) =>
      marker.label.props =
        text: text

    _refreshContainer = (container, x, y) =>
      container.props =
        x: x
        y: y

    _refreshContainer(@_container, _containerX, _containerY)
    _refreshMarker(@_needleMarker, _needleText)

  update: ->
    @_updateGuide()

  refresh: ->
    @_refreshGuide()


# Exports
exports.ScrollController = Controller
