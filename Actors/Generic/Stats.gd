extends Node

class_name Stats

export(Resource) var statsResource : Resource
export(int) var baseHealth = 100
var strength = 0 setget setStr
# Can set con to negative in order to lower health of enemies, but 0 is 100hp
var con = 0 setget setCon
var dex = 0 setget setDex

var health : int = 100 setget setHealth, getHealth
var maxHealth : int = 100 setget setMaxHealth, getMaxHealth
var attackSpeed : float = 1
var detectionRange : float = 1000
var leaveRange : float = 100
var itemDrops : Array = []
var dropChance := 0.1
var armorValue := 0

signal noHealth
signal healthChanged(value)
signal maxHealthChanged(value)
signal strChanged(value)
signal dexChanged(value)

func _ready():
	if statsResource:
		statsResource = statsResource as StatsResource
		con = statsResource.con
		strength = statsResource.strength
		dex = statsResource.dex
		# TODO: be better
		var detectionZone : DetectionZone = get_node("../DetectionZone")
		detectionZone.leaveRange = statsResource.leaveRange
		detectionZone.setDetectionRange(statsResource.detectionRange)
		itemDrops = statsResource.itemDrops
		dropChance = statsResource.dropChance
		armorValue = statsResource.armor
	maxHealth = baseHealth * pow(PlayerStats.conRatio, con)
	health = maxHealth
	
	self.attackSpeed = pow(PlayerStats.dexAttackRatio, dex)

func setMaxHealth(value : int):
	maxHealth = max(value, 1)
	self.health = min(health, maxHealth)
	emit_signal("maxHealthChanged", maxHealth)
	
func getMaxHealth():
	return maxHealth

func setHealth(value : int):
	health = clamp(value, 0, maxHealth)
	emit_signal("healthChanged", health)
	if (health <= 0):
		emit_signal("noHealth")
		
func getHealth():
	return health
	
func setStr(value):
	strength = value
	emit_signal("strChanged", value)
	
func setCon(value):
	con = value
	var oldMaxHealth = self.maxHealth
	self.maxHealth = int(baseHealth * pow(con, PlayerStats.conRatio))
	self.health += self.maxHealth - oldMaxHealth
	
func setDex(value):
	dex = value
	self.attackSpeed = pow(1/PlayerStats.dexAttackRatio, dex)
	emit_signal("dexChanged", value)

func _on_hurtbox_area_entered(_area):
	self.health -= 1
