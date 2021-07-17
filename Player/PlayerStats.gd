extends Node

var levelUpMenu = preload("res://UI/LevelUp.tscn")


var startingMaxHealth : int = 75 setget setStartingHealth
var maxHealth : int = startingMaxHealth setget setMaxHealth, getMaxHealth
var health = startingMaxHealth setget setHealth, getHealth
var baseSpeed : int = 150
var maxSpeed : float = baseSpeed
var playerLevel : int = 1 setget setPlayerLevel
# Used to help remember what level the player should be boosted to at the end of the next wave
var nextPlayerLevel : int = 1 setget setNextPlayerLevel
var currentXP : int = 0 setget setCurrentXP, getCurrentXP
var strength : int = 0 setget setStr
export(float) var strRatio := 1.2
var con : int = 0 setget setCon
var conRatio : float = 1.2
var conFrictionRatio : float = 1.1
var dex : int = 0 setget setDex
var dexMoveRatio : float = 1.025
var dexAttackRatio : float = .93
var dexDashRatio : float = .95
# Used for when player is wearing different types of armor
var speedModifier : float = 1.0
# AttackSpeed starts at 1 and then will slowly scale down as it's multiplied by weapon attack speed
var attackSpeed : float = 1
var invulnTimer : float = .6
var playerColor := Color("#327b38")

# Will be an array of scenes/references to scene instances
var inventory := []

signal noHealth
signal healthChanged(value)
signal maxHealthChanged(value)
signal currentXPChanged(newXP)
signal playerLevelChanged(newLevel)
signal nextLevelChanged(newLevel)
signal addedToInventory(newItem)
signal removedFromInventory(removedItem)

func _ready():
	self.maxHealth = startingMaxHealth
	self.health = maxHealth


func setStartingHealth(value):
	startingMaxHealth = value
	self.maxHealth = value
	self.health = value

func setMaxHealth(value : int):
	var oldMaxHealth = maxHealth
	maxHealth = max(value, 1)
	self.health += maxHealth - oldMaxHealth
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
	
func addXP(amount):
	self.setCurrentXP(currentXP + amount)
	
func xpToNextLevel() -> int:
	return 100 * nextPlayerLevel
	
func setCurrentXP(value):
	currentXP = value
	var nextLevelUp = xpToNextLevel()
	while currentXP >= nextLevelUp:
		currentXP -= nextLevelUp
		setNextPlayerLevel(nextPlayerLevel + 1)
	emit_signal("currentXPChanged", currentXP)
	
func getCurrentXP() -> int:
	return currentXP

func setStr(value):
	strength = value
	
func setCon(value):
	con = value
	self.maxHealth = int(startingMaxHealth * pow(conRatio, con))
	
func setDex(value):
	dex = value
	self.attackSpeed = pow(dexAttackRatio, dex)
	resetMaxSpeed()
	
func resetMaxSpeed():
	self.maxSpeed = self.baseSpeed * pow(dexMoveRatio, dex) * speedModifier

func setNextPlayerLevel(newLevel):
	nextPlayerLevel = max(nextPlayerLevel, max(playerLevel, newLevel))
	emit_signal("nextLevelChanged", nextPlayerLevel)

func incrementPlayerLevel():
	playerLevel += 1
	if playerLevel != 1:
		var newMenu = levelUpMenu.instance()
		newMenu.connect("upgradeChosen", self, "_emit_level_changed")
		var world = get_tree().current_scene.get_node("CanvasLayer")
		world.call_deferred("add_child", newMenu)
		get_tree().paused = true

# Starts a signal loop that will get player level up to newLevel
func setPlayerLevel(newLevel := nextPlayerLevel):
	nextPlayerLevel = newLevel
	if playerLevel < nextPlayerLevel:
		incrementPlayerLevel()
	else:
		playerLevel = nextPlayerLevel

func _emit_level_changed():
	get_tree().paused = false
	emit_signal("playerLevelChanged", playerLevel)
	if playerLevel < nextPlayerLevel:
		incrementPlayerLevel()

func addItemToInventory(item : Item):
	inventory.append(item)
	emit_signal("addedToInventory", item)
	
func removeItemFromInventory(item : Item):
	removeItemFromInvByPos(inventory.find(item))
	
func removeItemFromInvByPos(itemPos : int):
	if itemPos >= 0:
		var itemToRemove = inventory[itemPos]
		inventory.remove(itemPos)
		emit_signal("removedFromInventory", itemToRemove)
	
func getNumItemsOfType(name : String) -> int:
	var numItem = 0
	for i in range(len(inventory)):
		var item : Item = inventory[i]
		if name in item.get_name():
			numItem += 1
	
	return numItem
	
func getItemOfType(name : String) -> Item:
	for i in range(len(inventory)):
		var item : Item = inventory[i]
		if name in item.get_name():
			return item
			
	return null

func _on_hurtbox_area_entered(_area):
	self.health -= 1

func connectHealthChanged(node):
	self.connect("healthChanged", node, "_playerstats_health_changed")
	
func connectMaxHealthChanged(node):
	self.connect("maxHealthChanged", node, "_playerstats_maxhealth_changed")
	
func connectNoHealth(node : Node):
	self.connect("noHealth", node, "_playerstats_no_health")
