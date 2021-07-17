extends Control

onready var playerStats = get_node("/root/PlayerStats")

func _ready():
	Inventory.resetInventory()

func _on_ColorPicker_color_changed(color):
	playerStats.playerColor = color

