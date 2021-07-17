extends CanvasLayer

onready var label := $Label
onready var quitButton := $quitGame
onready var menuButton := $MenuButton
onready var resumeButton := $ResumeButton
onready var controlLabel := $ControlsLabel
onready var controlInfo := $controlsinfo
onready var background := $ColorRect

# If there are more than starting children, that means there is another menu active
var startingChildren : int

func _ready():
	label.visible = false
	resumeButton.connect("pressed", self, "togglePause")
	menuButton.connect("pressed", self, "togglePause")
	startingChildren = self.get_child_count()
	
func _process(_delta):
	if Input.is_action_just_pressed("pause") and startingChildren == self.get_child_count():
		togglePause()

func togglePause():
	var paused : bool = get_tree().paused
	get_tree().paused = not paused
	label.visible = not paused
	quitButton.visible = not paused
	menuButton.visible = not paused
	resumeButton.visible = not paused
	controlLabel.visible = not paused
	controlInfo.visible = not paused
	background.visible = not paused
	
	if not paused:
		background.modulate = Color(1,1,1,.3)
	else:
		background.modulate = Color(1,1,1,0)
