extends Hitbox

class_name WeaponHitbox

const strKnockbackRatio = 1.05

var fromPlayer: bool = false
var userStr: int = 0 setget setUserStr
var source
var hitboxOffset = 5
var weaponStats: WeaponStats
var weaponDamage: int
var baseDamage : int = 1 setget setBaseDamage
var baseKnockback : float setget setBaseKnockback
var weaponKnockback : float

onready var collision := $WeaponCollision
onready var parryCollision := $ParryHitbox/ParryCollision
onready var parrySfx := $ParrySFX

signal parried(area)

func setSource(newSource, sourceStr := 0):
	self.source = newSource
	fromPlayer = (self.source.name == "Player")
	setUserStr(sourceStr)
	
func setUserStr(value):
	userStr = value
	self.baseDamage = self.weaponDamage *  pow(PlayerStats.strRatio, self.userStr)
	self.baseKnockback = self.weaponKnockback * pow(strKnockbackRatio, self.userStr)

# Anytime base values are affected, current damage and knockback are reset
func setBaseDamage(value):
	baseDamage = value
	self.damage = baseDamage
	
func setBaseKnockback(value):
	baseKnockback = value
	self.knockbackValue = baseKnockback
	
func getSource():
	return self.source

func getSourcePos() -> Vector2:
	return self.source.global_position
	
func setWeapon(weapon : WeaponStats):
	weaponStats = weapon
	weaponDamage = weapon.damage
	weaponKnockback = weapon.knockbackValue
	self.baseDamage = self.weaponDamage *  pow(PlayerStats.strRatio, self.userStr)
	self.baseKnockback = weaponStats.knockbackValue * pow(strKnockbackRatio, self.userStr)
		
	if weaponStats.weaponType == WeaponStats.WeaponType.RANGED or weaponStats.weaponType == WeaponStats.WeaponType.AOE:
		#is ranged, no local weapon collision
		collision.position.x = 0
		parryCollision.position.x = 0
	else:
		# Position the collision boxes to the right side of the player
		collision.position.x = weaponStats.length/2 + weaponStats.radius + hitboxOffset
		parryCollision.position.x = weaponStats.length/2 + weaponStats.radius + hitboxOffset
		
	# Create a new shape of the proper size for the loaded weapon
	var shape : CapsuleShape2D = CapsuleShape2D.new()
	shape.height = weaponStats.length
	shape.radius = weaponStats.radius
	collision.shape = shape
	parryCollision.shape = shape

# TODO: there may be a better way to do this so that we don't actually change the base value
# This might cause issues with like forgetting to reset value after combo
# Should really only be used for a combo scaling
func scaleDamage(scalar := 1.0):
	self.damage = max(float(baseDamage) * scalar, 1)
	
func scaleKnockback(scalar := 1.0):
	self.knockbackValue = baseKnockback * scalar

# Let everyone know that you've been parried
func parry(area : WeaponHitbox):
	parrySfx.play()
	emit_signal("parried", area)
