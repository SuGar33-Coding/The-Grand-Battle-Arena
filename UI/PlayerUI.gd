extends CanvasLayer

var flashCounter = 0
# Must be an even number
var maxFlashes = 6
var timeBetweenFlashes = .05

onready var inventory : Inventory = get_node("/root/Inventory")
onready var healthbar : ProgressBar = $HBoxContainer/VBoxContainer/HealthbarContainer/Healthbar
onready var xpbar : ProgressBar = $HBoxContainer/VBoxContainer/HBoxContainer/XPbar
onready var lvllabel : Label = $HBoxContainer/VBoxContainer/HBoxContainer/LvlLabel
onready var healthbarLabel : Label = $HBoxContainer/VBoxContainer/HealthbarContainer/Healthbar/HealthbarLabel
onready var xpbarLabel : Label = $HBoxContainer/VBoxContainer/HBoxContainer/XPbar/XPbarLabel
onready var coinLabel : Label = $HBoxContainer/PanelContainer/HBoxContainer/CoinLabel
onready var stats = get_node("/root/PlayerStats")
onready var animationPlayer := $AnimationPlayer
onready var hpTween := $HPTween
onready var timer := $Timer

func _ready():
	self._playerstats_health_changed(stats.health)
	self._player_xp_changed(stats.currentXP)
	stats.connectHealthChanged(self)
	stats.connect("currentXPChanged", self, "_player_xp_changed")
	stats.connect("playerLevelChanged", self, "_player_level_changed")
	stats.connect("nextLevelChanged", self, "_next_level_changed")
	timer.connect("timeout", self, "_timer_timeout")
	inventory.connect("coins_changed", self, "_coins_changed")
	
func setHealthbarValue(value : float):
	if hpTween.is_active():
		hpTween.remove_all()
	
	# Only flash when there is damage
	if healthbar.value > value:
		flashCounter = 0
		timer.start(timeBetweenFlashes)
	
	hpTween.interpolate_property(healthbar, "value", healthbar.value, value, maxFlashes * timeBetweenFlashes, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	hpTween.start()

func setXPbarValue(value : float):
	xpbar.value = value

func _playerstats_health_changed(value):
	var newBarVal = float(value) / stats.getMaxHealth() * 100
	if newBarVal < healthbar.value:
		pass#animationPlayer.play("DamageTaken")
	self.setHealthbarValue(newBarVal)
	healthbarLabel.text = str(value) + " / " + str(stats.getMaxHealth())

func _player_xp_changed(newXP):
	self.setXPbarValue(float(newXP) / stats.xpToNextLevel() * 100)
	xpbarLabel.text = str(int(newXP)) + " / " + str(stats.xpToNextLevel())
	
func _player_level_changed(_newLevel):
	lvllabel.text = "Lvl: " + str(stats.playerLevel)

func _next_level_changed(_newLevel):
	lvllabel.text = "Lvl: " + str(stats.playerLevel) + " (" + str(stats.nextPlayerLevel) + ") "

func _timer_timeout():
	# If counter is even, go white
	if flashCounter % 2 == 0:
		healthbar.modulate = Color(10,10,10,1)
	else:
		healthbar.modulate = Color(1,1,1,1)
		
	flashCounter += 1
	if flashCounter < maxFlashes:
		timer.start(timeBetweenFlashes)

func _coins_changed(newValue):
	coinLabel.text = str(newValue)
