![ScrollController](assets/cover.png)
# ScrollController

ScrollController is a Framer module that helps you to animate, pin and trigger events based on scroll position. It's the module you need, if you want to:

- animate based on scroll position
- start an animation at a specific scroll position
- synchronise an animation to the scroll movement
- pin a layer indefinitely at a specific scroll position
- pin a layer for a limited amount of scroll progress
- add callbacks at specific scroll positions passing a progress parameter
- easily create parallax effect
- create infinite scrolling
- create sticky headers

_Works with [Framer](https://framer.com) v120 or later_

#### Table of contents
[Installation](#installation)  
[Quick start](#quick-start)  
[Documentation](#documentation)
[Known limitations](#known-limitations)  
[Releases](#releases)  
[License](#license)  
[Author](#author)  
[Acknowledgement](#acknowledgement)  

## Installation

#### Install with Framer Modules

1. Open your project in Framer.
2. Start Framer Modules and select `ADD MODULE`.
3. Search for `ScrollController`, once found hit enter to install into your prototype.

<a href='https://open.framermodules.com/scrollcontroller'>
    <img alt='Install with Framer Modules'
    src='https://www.framermodules.com/assets/badge@2x.png' width='160' height='40' />
</a>

#### Install manually

1. Open your project in Framer.
2. Download and unzip the module.
3. Drag the file `ScrollController.coffee` into the code editor.
4. Change `ScrollController` to `{ScrollController}` in the require command

<a href="https://github.com/jbentzen/framer-scrollcontroller/releases/download/v1.0.0/scrollcontroller.zip">
  <img img width="110" height="40" src="assets/download.png">
</a>

## Quick start
To get started using the `ScrollController` you must start by creating a `Controller` to make the required connection to the `ScrollComponent`. Secondly you must add at least one `Scene` which defines in what part of the page something should happen. Finally you must add at least one `Tween` or `Pin` to define what needs to happen.

##### Step 1: Import module
```coffee
# Import module
{ScrollController} = require 'ScrollController'
```

##### Step 2: Create setting (with built-in components)  
```coffee
# Create ScrollComponent
myScrollComponent = new ScrollComponent
	frame: Screen.frame
	scrollHorizontal: false

# Create container
myContainer = new Layer
	parent: myScrollComponent.content
	width: Screen.width
	height: Screen.height*2
	backgroundColor: null

# Create layer
myLayer = new Layer
	parent: myContainer
	point: Align.center
```

##### Step 3: Create controller and add scene, tween and pin
```coffee
# Create controller
myController = new ScrollController
	source: myScrollComponent

# Add scene
myScene = myController.addScene
	triggerLayer: myLayer
	duration: 200
	guide: true

# Add tweeen
myScene.addTween
	to: {rotation: -90, scale: 0.2, backgroundColor: "#00AAFF"}
	options: {time: 0.25, curve: "Spring"}

# Add pin
myScene.addPin()
```

## Documentation
ScrollController consists of 4 components: `Controller`, `Scene`, `Tween` and `Pin`. Learn about each components properties in the documentation:

#### Components
[Controller](#controller)  
[Scene](#scene)  
[Tween](#tween)  
[Pin](#pin)

### Controller
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| [`new ScrollController`](#new-Controller) | Class | - | Create controller |
| `Controller.source` | Object | - | Get controller source |
| `Controller.name` | String | `"."` | Get/Set controller name |
| `Controller.direction` | String | `"vertical"` | Get controller scroll direction |
| `Controller.throttle` | Number | `0` | Get/Set controller throttling |
| `Controller.enabled` | Boolean | `true` | Get/Set controller enabled state |
| [`Controller.addScene`](#controller.addscene) | Method | - | Add scene to controller |
| [`Controller.removeScene`](#controller.removescene) | Method | - | Remove scene from controller |
| [`Controller.scrollTo`](#controller.scrollto) | Method | - | Scroll to scene, progress, layer or offset |
| [`Controller.update`](#controller.update) | Method | - | Force controller update |
| [`Controller.refresh`](#controller.refresh) | Method | - | Force controller refresh |
| [`Controller.remove`](#controller.remove) | Method | - | Remove controller |

#### new ScrollController
Create controller.

##### Parameters:
- `source` – ScrollComponent instance – _required_
- `name` – controller name
- `direction` – controller scroll direction
- `throttle` – controller throttling
- `enabled` – controller enabled state

```coffee
# Create controller with default properties
myController = new ScrollController
  source: myScrollComponent

# Create controller with custom properties
myController = new ScrollController
  source: myScrollComponent
  name: "myControllerName"
  direction: "horizontal"
  throttle: 0.01
  enabled: false
```

#### Controller.addScene
Add scene to controller.

##### Parameters:
- `name` – scene name
- `triggerLayer` – scene triggerLayer to define the start of the scene
- `offset` – scene offset, from top/left of screen or from triggerLayer
- `duration` – scene duration
- `needle` – scene needle position, from begining to end of screen (0-1)
- `reverse` – scene reverse state
- `enabled` – scene enabled state
- `guide` – scene guide indicators
- `guideNeedleColor` – scene guide needle color
- `guideStartColor` – scene guide start color
- `guideEndColor` – scene guide end color
- `guideIndent` – scene guide indent

```coffee
# Add scene to controller with default properties
myController.addScene()

# Add scene to controller with custom properties
myController.addScene
  name: "mySceneName"
  triggerLayer: myLayer
  offset: 100
  duration: -200
  needle: 0.65
  reverse: false
  enabled: false
  guide: true
  guideNeedleColor: "blue"
  guideStartColor: "green"
  guideEndColor: "red"
  guideIndent: 40
```

#### Controller.removeScene
Remove scene from controller.

##### Parameters:
- `reset` – reset scene and all connected tweens and pins

```coffee
# Remove scenes and all connected tweens and pins
myController.removeScene myScene

# Remove and reset scene and all connected tweens and pins
myController.removeScene myScene, true
```

#### Controller.scrollTo
Scroll to scene, scene progress, layer and offset

##### Parameters:
- `element` – scene or layer
- `progress` – scene progress (0-1)
- `offset` – offset

```coffee
# Scroll to scene
myController.scrollTo
  element: myScene

# Scroll to scene progress
myController.scrollTo
  element: myScene
  progress: myScene.progress

# Scroll to layer
myController.scrollTo
  element: myLayer

# Scroll to offset
myController.scrollTo
  offset: 100

# Scroll to scene progress with offset
myController.scrollTo
  element: myScene
  progress: myScene.progress
  offset: 100
```

#### Controller.update
Update controller by recalculating scene, tween and pin properties then automatically refreshing the controller. This happens automatically and should only be used when required.

```coffee
# Update controller
myController.update()
```

#### Controller.refresh
Refresh controller by redrawing scenes, tweens and pins. This happens automatically and should only be used when required.

```coffee
# Refresh controller
myController.refresh()
```

#### Controller.remove
Remove controller.

##### Parameters:
- `reset` – reset controller and all connected scenes, tweens and pins

```coffee
# Remove controller and all connected scenes, tweens and pins
myController.remove()

# Remove and reset controller and all connected scenes, tweens and pins
myController.remove true
```


### Scene
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `Scene.source` | Object | `ScrollComponent` | Get scene ScrollComponent |
| `Scene.controller` | Object | `Controller` | Get scene controller |
| `Scene.name` | String | `"."` | Get/Set scene name |
| `Scene.triggerLayer` | Layer | `Undefined` | Get/Set triggerLayer |
| `Scene.needle` | Number | `0.5` | Get/Set scene needle (0-1) |
| `Scene.offset` | Number | `0` | Get/Set scene offset |
| `Scene.duration` | Number | `0` | Get/Set scene duration |
| `Scene.reverse` | Boolean | `true` | Get/Set scene reverse state |
| `Scene.enabled` | Boolean | `true` | Get/Set scene enabled state |
| `Scene.guide` | Boolean | `false` | Get scene guide |
| `Scene.guideNeedleColor` | Color | `"#0066FF"` | Get scene guide needle guide |
| `Scene.guideStartColor` | Color | `"#009933"` | Get scene guide start color |
| `Scene.guideEndColor` | Color | `"#FF3333"` | Get scene guide end color |
| `Scene.state` | String | `"before"`, `"during"` or `"after"` | Get scene state |
| `Scene.progress` | Number | - | Get scene progress (0-1) |
| `Scene.start` | Number | - | Get scene start |
| `Scene.end` | Number | - | Get scene end |
| `Scene.needlePos`| Number | - | Get scene needle position |
| `Scene.scrollOffset` | Number | - | Get scene scroll offset |
| `Scene.offsetStart` | Number | - | Get scene offset start |
| `Scene.offsetEnd`| Number | - | Get scene offset end |
| `Scene.tweens` | Array | - | Get scene tweens |
| `Scene.pins` | Array | - | Get scene pins |
| [`Scene.addTween`](#scene.addtween) | Method | - | Add scene tween |
| [`Scene.removeTween`](#scene.removetween) | Method | - | Remove scene tween |
| [`Scene.addPin`](#scene.addpin) | Method | - | Add scene pin |
| [`Scene.removePin`](#scene.removepin) | Method | - | Remove scene pin |
| [`Scene.trigger`](#scene.trigger) | Method | - | Trigger scene event |
| [`Scene.update`](#scene.update) | Method | - | Force scene update |
| [`Scene.refresh`](#scene.refresh) | Method | - | Force scene refresh |
| [`Scene.remove`](#scene.remove) | Method | - | Remove scene |
| [`Scene.onChangeValue`](#scene.onevent) | Event | - | On change value |
| [`Scene.onShift`](#scene.onevent) | Event | - | On shift |
| [`Scene.onUpdate`](#scene.onevent) | Event | - | On update |
| [`Scene.onEnter`](#scene.onevent) | Event | - | On enter |
| [`Scene.onStart`](#scene.onevent) | Event | - | On start |
| [`Scene.onProgress`](#scene.onevent) | Event | - | On progress |
| [`Scene.onEnd`](#scene.onevent) | Event | - | On end |
| [`Scene.leave`](#scene.onevent) | Event | - | On leave |

#### Scene.addTween
Add tween to scene.

##### Parameters:
- `name` – tween name
- `layer` – tween layer
- `from` – tween from properties object - _required if no to properties_
- `to` – tween to properties object - _required if no from properties_
- `options` – tween animation object
- `init` – tween initialisation state
- `enabled` – tween enabled state

```coffee
# Add tween to scene with default properties
myScene.addTween
  from: {opacity: 0}

# Add tween to scene with custom properties
myScene.addTween
  name: "myTween"
  layer: myOtherLayer
  from: {rotation: 0, scale: 2, backgroundColor: "white"}
  to: {rotation: -90, scale: 0.2, backgroundColor: "#00AAFF"}
  options: {time: 0.25, curve: "Spring", colorModel: "rgb"}
  init: true
  enabled: false
```

#### Scene.removeTween
Remove tween from scene.

##### Parameters:
- `reset` – reset tween

```coffee
# Remove tween
myScene.removeTween myTween

# Remove and reset tween
myScene.removeTween myTween, true
```

#### Scene.addPin
Add pin to scene.

##### Parameters:
- `name` – pin name
- `layer` – pin layer
- `enabled` – pin enabled state

```coffee
# Add pin to scene with default properties
myScene.addPin()

# Add pin to scene with custom properties
myScene.addPin
  name: "myPinName"
  layer: myOtherLayer
  enabled: false
```

#### Scene.removePin
Remove pin from scene.

##### Parameters:
- `reset` – reset pin

```coffee
# Remove pin
myScene.removePin myPin

# Remove and reset pin
myScene.removePin myPin, true
```

#### Scene.trigger
Trigger scene event.

##### Parameters:
- `name` – event name to trigger – _required_
- `event` – event object for callback

```coffee
# Trigger scene event
myScene.trigger
  name: "enter"
  event: {myVar}
```

#### Scene.update
Update by recalculating scene, tween and pin properties then automatically refreshing the scene. This happens automatically and should only be used when required.

```coffee
# Update scene
myScene.update()
```

#### Scene.refresh
Refresh scene by redrawing tweens and pins. This happens automatically and should only be used when required.

```coffee
# Refresh scene
myScene.refresh()
```

#### Scene.remove
Remove scene from controller.

##### Parameters:
- `reset` – reset scene and all connected tweens and pins

```coffee
# Remove scene and all connected tweens and pins
myScene.remove()

# Remove and reset scene and all connected tweens and pins
myScene.remove true
```

#### Scene.onEvent
Listen for scene events.

##### Event listeners
```coffee
# Listen for scene change
myScene.onChangeValue ->
  print "Scene changed"

# Listen for scene shift
myScene.onShift ->
  print "Scene shifted"

# Listen for scene update
myScene.onUpdate ->
  print "Scene updated"

# Listen for scene enter
myScene.onEnter ->
  print "Scene entered"

# Listen for scene start
myScene.onStart ->
  print "Scene started"

# Listen for scene progress
myScene.onProgress ->
  print "Scene progressed"

# Listen for scene end
myScene.onEnd ->
  print "Scene ended"

# Listen for scene leave
myScene.onLeave ->
  print "Scene left"
```

##### Event listeners with callbacks
```coffee
# Listen for scene change with callback
myScene.onChangeValue event, instance, ->
  print "Scene changed"
  print "Event: #{event.property}, #{event.value}"

# Listen for scene shift with callback
myScene.onShift event, instance, ->
  print "Scene shifted"
  print "Event: #{event.reason}"

# Listen for scene update with callback
myScene.onUpdate event, instance, ->
  print "Scene updated"
  print "Event: #{event.start}, #{event.end}, #{event.scrollPos}"

# Listen for scene enter with callback
myScene.onEnter event, instance, ->
  print "Scene entered"
  print "Event: #{event.progress}, #{event.state}, #{event.scrollDir}"

# Listen for scene start with callback
myScene.onStart event, instance, ->
  print "Scene started"
  print "Event: #{event.progress},#{event.state}, #{event.scrollDir}"

# Listen for scene progress with callback
myScene.onProgress event, instance, ->
  print "Scene progressed"
  print "Event: #{event.progress},#{event.state}, #{event.scrollDir}"

# Listen for scene end with callback
myScene.onEnd event, instance, ->
  print "Scene ended"
  print "Event: #{event.progress},#{event.state}, #{event.scrollDir}"

# Listen for scene leave with callback
myScene.onLeave event, instance, ->
  print "Scene left"
  print "Event: #{event.progress},#{event.state}, #{event.scrollDir}"
```


### Tween
| Property | Type | Default | Description |
| :--- | :--- | :--- |  :--- |
| `Tween.source` | Object | `ScrollComponent` | Get tween ScrollComponent |
| `Tween.controller` | Object | `Controller` | Get tween controller |
| `Tween.scene` | Object | `Scene` | Get tween scene |
| `Tween.name` | String | `"."` | Get/Set tween name |
| `Tween.layer` | Object | `Scene.triggerLayer` | Get tween layer |
| `Tween.from` | Object | - | Get tween from properties |
| `Tween.to` | Object | - | Get tween to properties |
| `Tween.options` | Object | `Framer.Defaults.Animation` | Get tween animation options |
| `Tween.init` | Boolean | `true` | Get tween animation initialisation state |
| `Tween.enabled` | Boolean | `true` | Get/Set tween enabled state |
| [`Tween.remove`](#Tween.remove) | Method | - | Remove tween |

#### Tween.remove
Remove tween from scene.

##### Parameters:
- `reset` – reset tween

```coffee
# Remove tween
myTween.remove()

# Remove and reset tween
myTween.remove true
```


### Pin
| Property | Type | Default |  Description |
| :--- | :--- | :--- | :--- |
| `Pin.source` | Object | `ScrollComponent` | Get pin ScrollComponent |
| `Pin.controller` | Object | `Controller` | Get pin controller |
| `Pin.scene` | Object | `Scene` | Get pin scene |
| `Pin.name` | String | `"."` | Get/Set pin name |
| `Pin.layer` | Layer | `Scene.triggerLayer` | Get pin layer |
| `Pin.enabled` | Boolean | `true` | Get/Set pin enabled state |
| `Pin.state` | String | `"pinned"` or `"unpinned"` | Get pin state |
| [`Pin.remove`](#Pin.remove) | Method | - | Remove pin |

#### Pin.remove
Remove pin from scene.

##### Parameters:
- `reset` – reset pin

```coffee
# Remove pin
myPin.remove()

# Remove and reset pin
myPin.remove true
```


## Known limitations

- It is not recommended to use ScrollController for “clicky” mousewheel scrolling due to the nature of its scrolling behavior.
- Overlapping pins on the same layer in the same direction is not supported, use successive pinning instead.
- Successive tweening requires the use of both `from`, `to` and `init: false` for all but the first tween.
- Removing tweens on a layer with remaining tweens is not supported.

## Releases
- v1.0.0 - Initial release

## License
This project is licensed under the [MIT license](LICENSE).

## Author
Developed by Jesper Bentzen.

- Website: [jesperbentzen.com](http://jesperbentzen.com)
- Twitter: [@jbentzen](https://twitter.com/jbentzen)

Star this repository if you like it, and if you find that this plugin somehow saves your day, then consider buying me a coffee via PayPal. It will surely help motivate me to further support this module. :)

<a href="https://www.paypal.me/jesperbentzen/">
  <img img width="143" height="40" src="assets/paypal.png">
</a>

## Acknowledgement
A special thank you to [@janpaepke](https://github.com/janpaepke) for creating [ScrollMagic](http://scrollmagic.io) which helped guide the approach used in this module. Also thank you to the entire Framer Slack community and especially [@steveruizok](https://github.com/steveruizok) and [@marckrenn](https://github.com/marckrenn) for sharing their thoughts and hard work to study and build upon.
