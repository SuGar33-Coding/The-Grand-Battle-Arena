extends CanvasLayer

onready var strButton = $PanelContainer/MarginContainer/HBoxContainer/StrButton
onready var conButton = $PanelContainer/MarginContainer/HBoxContainer/ConButton
onready var dexButton = $PanelContainer/MarginContainer/HBoxContainer/DexButton
onready var animationPlayer = $AnimationPlayer
onready var levelLabel := $LevelLabel
onready var strLabel := $PanelContainer/MarginContainer/HBoxContainer/StrButton/VBoxContainer/HBoxContainer/StrLabel
onready var conLabel := $PanelContainer/MarginContainer/HBoxContainer/ConButton/VBoxContainer/HBoxContainer/ConLabel
onready var dexLabel := $PanelContainer/MarginContainer/HBoxContainer/DexButton/VBoxContainer/HBoxContainer/DexLabel

signal upgradeChosen()

func _ready():
	strButton.connect("pressed", self, "_str_button_pressed")
	conButton.connect("pressed", self, "_con_button_pressed")
	dexButton.connect("pressed", self, "_dex_button_pressed")
	animationPlayer.play("FadeIn")
	levelLabel.text = "New Level: " + str(PlayerStats.playerLevel)
	strLabel.text = str(PlayerStats.strength)
	conLabel.text = str(PlayerStats.con)
	dexLabel.text = str(PlayerStats.dex)
	
func _str_button_pressed():
	PlayerStats.strength += 1
	emit_signal("upgradeChosen")
	queue_free()
	
func _con_button_pressed():
	PlayerStats.con += 1
	emit_signal("upgradeChosen")
	queue_free()
	
func _dex_button_pressed():
	PlayerStats.dex += 1
	emit_signal("upgradeChosen")
	queue_free()

func printStats():
	print("Str: ", PlayerStats.strength)
	print("Con: ", PlayerStats.con)
	print("Dex: ", PlayerStats.dex)
	print()
