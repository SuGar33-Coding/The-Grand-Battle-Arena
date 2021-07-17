extends KinematicBody2D

class_name RangedProjectile

# Accuracy timing thresholds
const CRIT = 0.1
const HALF_CRIT = 0.2
const NORMAL = 0.5
const REDUCED = 0.75

var fromPlayer : bool = false
var speed
var velocity := Vector2.ZERO
var weaponStats : WeaponStats
var source
var accuracy : float
var userStr : int
var HitEffect = preload("res://FX/HitEffect.tscn")

onready var weaponHitbox := $WeaponHitbox
onready var sprite := $Sprite
onready var collision := $CollisionShape2D

func init(weaponStats: WeaponStats, source, sourceStr: int, acc := NORMAL):
	self.weaponStats = weaponStats
	self.source = source
	self.accuracy = acc
	
	# Ranged stuff scales less with strength
	self.userStr = sourceStr * 3/4
	
	self.fromPlayer = (source.name == "Player")

func _ready():
	weaponHitbox.setWeapon(weaponStats)
	weaponHitbox.setSource(source, userStr)
	
	if accuracy >= 0:
		if accuracy <= CRIT:
			weaponHitbox.scaleDamage(2)
		elif accuracy <= HALF_CRIT:
			weaponHitbox.scaleDamage(1.5)
		elif accuracy <= NORMAL:
			weaponHitbox.scaleDamage(1)
		elif accuracy <= REDUCED:
			weaponHitbox.scaleDamage(.5)
		else:
			weaponHitbox.scaleDamage(.1)
	else: 
		# If negative, check portion of attackspeed that we were off
		accuracy = abs(accuracy)/ (max(weaponStats.attackSpeed * PlayerStats.attackSpeed, .5))
		if accuracy <= .1:
			weaponHitbox.scaleDamage(1)
		elif accuracy <= .25:
			weaponHitbox.scaleDamage(.5)
		else:
			weaponHitbox.scaleDamage(.1)
	
	speed = weaponStats.projectileSpeed
	
	sprite.texture = weaponStats.projectileTexture
	
	weaponHitbox.connect("area_entered", self, "_area_entered")
	$WeaponHitbox/ParryHitbox.connect("area_entered", self, "_area_entered")
	
func _physics_process(delta):
	# move_and_collide returns any objects being collided with
	var move = move_and_collide(velocity * delta)
	if move != null:
		# Kills if runs into a wall
		self.killSelf()

func fire(startingPosition : Vector2, startingRotation : float):
	
	# TODO: Temporarily if it is from player then change its layer mask, will eventually do this with groups instead
	if fromPlayer:
		self.weaponHitbox.set_collision_mask_bit(4, false)
		self.weaponHitbox.set_collision_mask_bit(5, true)
	self.global_position = startingPosition
	self.global_rotation = startingRotation
	velocity =  Vector2(1,0).rotated(self.global_rotation) * speed
	
func killSelf():
	var hitEffect = HitEffect.instance()
	hitEffect.global_position = global_position
	hitEffect.init(global_position + velocity.normalized() * self.collision.shape.height)
	
	var world = get_tree().current_scene
	world.add_child(hitEffect)
	queue_free()

func _area_entered(_area):
	queue_free()
