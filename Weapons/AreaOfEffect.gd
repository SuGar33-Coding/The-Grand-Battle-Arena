# The AreaOfEffect class functions a lot like a ranged projectile
# Except that it should be given a position away from the user and have 
# little to no velocity.  An AOE effect does not die on first contact
# like a projectile does
extends KinematicBody2D

class_name AreaOfEffect

# Accuracy timing thresholds
const THRESHOLD = 10

# number of damage ticks
var totalTicks := 2
var numTicks := 0
var lifetime := 1.0
var fromPlayer : bool = false
var speed
var velocity := Vector2.ZERO
var weaponStats : WeaponStats
var source
var userStr : int
var HitEffect = preload("res://FX/HitEffect.tscn")
var aoeEffect : AoeFX
var targetPosition := Vector2.ZERO
# Whether you need to check the logic in physics process
var checkPosition := false
var fired := false

onready var weaponHitbox := $WeaponHitbox
onready var collision := $CollisionShape2D
onready var tickTimer := $TickTimer
onready var hurtTimer := $HurtTimer
onready var particles := $Particles2D
onready var sprite := $Sprite
onready var animationPlayer := $AnimationPlayer
onready var crosshair := $CrosshairSprite

func init(weaponStats: WeaponStats, source, sourceStr: int, lifetime: float, numberOfTicks: int):
	self.weaponStats = weaponStats
	self.source = source
	self.totalTicks = numberOfTicks
	self.lifetime = lifetime
	
	# AOE stuff scales less with strength
	self.userStr = sourceStr * 1/3
	
	self.fromPlayer = (source.name == "Player")
	
	

func _ready():
	weaponHitbox.setWeapon(weaponStats)
	weaponHitbox.setSource(source, userStr)
	
	# Crosshair radius is 20, so scale that to aoe
	crosshair.scale.x = .33333
	crosshair.scale.y = .33333
	crosshair.visible = false
	
	tickTimer.connect("timeout", self, "_tick_timeout")
	hurtTimer.connect("timeout", self, "_hurt_timeout")
	
	speed = weaponStats.projectileSpeed
	
	# TODO: Reposition so that YSORT position is much lower
	aoeEffect = weaponStats.aoeEffect
	
	particles.emitting = false
	
	particles.process_material = aoeEffect.effectMaterial
	
	particles.lifetime = aoeEffect.particleLifetime
	
	particles.amount = aoeEffect.numParticles
	
	particles.speed_scale = aoeEffect.speedScale
	
func _physics_process(delta):
	var move = move_and_collide(velocity * delta)
	
	if( (not aoeEffect.aoeType == AoeFX.AoeType.LOBBED and move != null) or (checkPosition and targetPosition.distance_to(self.global_position) < THRESHOLD)):
		checkPosition = false
		self.enableAoe()
		velocity = Vector2.ZERO
	
	if(fired):
		crosshair.global_position = targetPosition

# TODO: Change crosshair to be its own scene rather than a child of aoe
func fire(userPosition : Vector2, targetPosition : Vector2, startingRotation := 0.0):
	
	weaponHitbox.collision.set_deferred("disabled", true)
	
	weaponHitbox.global_rotation = startingRotation
	
	crosshair.global_position = targetPosition
	crosshair.visible = true
	
	fired = true
	
	self.targetPosition = targetPosition
	# TODO: Temporarily if it is from player then change its layer mask, will eventually do this with groups instead
	if fromPlayer:
		self.weaponHitbox.set_collision_mask_bit(4, false)
		self.weaponHitbox.set_collision_mask_bit(5, true)
	match aoeEffect.aoeType:
		AoeFX.AoeType.PLACE:
			# Aoe spawns on given point
			self.global_position = targetPosition
			particles.emitting = true
			
			self.enableAoe()
			
		AoeFX.AoeType.RANGED:
			# Projectile originating from the user that bursts into an aoe
			self.global_position = userPosition
			velocity =  Vector2(1,0).rotated(startingRotation) * speed
			
			checkPosition = true
			sprite.texture = weaponStats.projectileTexture
			sprite.global_rotation = startingRotation
			sprite.set_deferred("visible", true)
		AoeFX.AoeType.LOBBED:
			# Has an arched projectile originating from the user that bursts into an aoe
			self.global_position = userPosition
			velocity =  Vector2(1,0).rotated(startingRotation) * (userPosition.distance_to(targetPosition)/aoeEffect.chargeupTime)
			
			sprite.texture = weaponStats.projectileTexture
			sprite.global_rotation = startingRotation
			sprite.set_deferred("visible", true)
			
			# Use animation player to have the projectile make an arch
			animationPlayer.playback_speed = 1/aoeEffect.chargeupTime
			animationPlayer.play("Lob")
			
		AoeFX.AoeType.MOVING:
			# Aoe spawns on given point and continues moving forward damagin in its path
			self.global_position = targetPosition
			velocity =  Vector2(1,0).rotated(startingRotation) * speed
			
			self.enableAoe()
			
	# May need to use this if we want aoe to be able to move (like a tornado
	"""if(weaponStats.aoeAngle >= 0):
		self.global_rotation = startingRotation + weaponStats.aoeAngle
	else:
		self.global_rotation = 0"""
	
# Starts the particle and damaging affects of the aoe
func enableAoe():
	sprite.set_deferred("visible", false)
	
	# We want ysort to be better so move all of the visuals up but the root node down
	self.global_position.y += aoeEffect.ysortOffset
	particles.global_position.y -= aoeEffect.ysortOffset
	weaponHitbox.global_position.y -= aoeEffect.ysortOffset
	
	crosshair.visible = false
	
	particles.set_deferred("emitting", true)
	
	if(weaponStats.instantTick):
		_tick_timeout()
		tickTimer.start(lifetime / totalTicks-1)
	else:
		tickTimer.start(lifetime / totalTicks)

	
func stopMovement():
	velocity = Vector2.ZERO
	
func killSelf():
	# TODO: Instead have a stop emitting function that stops emitting and kills itself after full lifetime
	queue_free()

# Tick Timer loops automatically, turn off and on collision box every tick
# in order to redo damage
func _tick_timeout():
	weaponHitbox.collision.set_deferred("disabled", false)
	# Turn on hitbox for .1 seconds to do damage and turn off otherwise
	hurtTimer.start(.1)
	

func _hurt_timeout():
	weaponHitbox.collision.set_deferred("disabled", true)
	numTicks += 1
	if numTicks >= totalTicks:
		killSelf()
