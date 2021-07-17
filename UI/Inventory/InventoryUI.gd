extends CanvasLayer

onready var controlNode := $Control

func _ready():
	controlNode.visible = false


func _process(_delta):
	if Input.is_action_just_pressed("toggleInventory"):
		toggleVisible()


func toggleVisible():
	controlNode.visible = not controlNode.visible
