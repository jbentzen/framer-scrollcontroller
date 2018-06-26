# Create setting (with built-in components)
# ----------------------------------------------------------

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


# Create controller and add scene, tween and pin
# ----------------------------------------------------------

# Create controller
myController = new ScrollController
	source: myScrollComponent

# Add scene
myScene = myController.addScene
	triggerLayer: myLayer
	duration: 200
	guide: true

# Add tweeen
myTween = myScene.addTween
	to: {rotation: -90, scale: 0.2, backgroundColor: "#00AAFF"}
	options: {time: 0.25, curve: "Spring"}

# Add pin
myPin = myScene.addPin()
