extends Fighter

export(int) var maxBurstRange = 250
export(int) var minBurstRange = 150
export(float) var burstTimeMax = 12
export(float) var burstTimeMin = 7
export(float) var BurstAcceleration = 12000
export(float) var BaseBurstSpeed = 600 

var collisionChecker = preload("res://Actors/Zones/CollisionCheck.tscn")
var groundPoundFx = preload("res://FX/GroundPoundFx.tscn")
var bursting : bool = false setget setBursting
var BurstSpeed : float = 5000
var poundRange : float
var burstTarget : Vector2 = Vector2.ZERO

onready var burstTimer := $BurstTimer
onready var poundHitbox := $AttackPivot/GroundPoundHitbox

func _ready():
	poundRange = poundHitbox.hitboxRadius + poundHitbox.hitboxHeight

# TODO add specific burst target
func _physics_process(_delta):
	if bursting and is_instance_valid(target) and state == State.CHASE:
		if self.global_position.distance_to(target.global_position) < poundRange or self.global_position.distance_to(burstTarget) < poundRange or get_slide_count() > 0:
			playGroundPound()

# When in range I want to stop and charge up :: Use attack state to stop us
# Then I want to reenter chase to start moving toward target, but prevent reenteringa ttack state :: use boolean
# When I land I want to set a timer between bursts and allow to enter normal attack state
func switchToAttack():
	if bursting:
		state = State.ATTACK
		animationPlayer.playback_speed = 1
		animationPlayer.play("Leap")
		var animLength = animationPlayer.current_animation_length
		BurstSpeed = BaseBurstSpeed
		burstTimer.start(rand_range(burstTimeMin, burstTimeMax)+animLength)
	elif attackTimer.is_stopped():
		.switchToAttack()
	
func willAttack() -> bool:
	if not bursting:
		if canBurst():
			bursting = true
			return bursting
		else:
			bursting = false
			return .willAttack()
	else:
		return false

# TODO: Reimpliment stun shield while ground pounding/bursting
func willStun() -> bool:
	return not bursting

func lookAtTarget():
	#if bursting:
	#	attackPivot.rotation = 0
	#else:
	attackPivot.lookAtTarget(detectionZone.target.position)

func slowBurstSpeed():
	BurstSpeed *= .1
	
func stopBurstSpeed():
	BurstSpeed = 0
	
func playGroundPound():
	animationPlayer.playback_speed = 1
	animationPlayer.play("GroundPound")
	
func setBurstTargetPos():
	burstTarget = target.global_position
	if self.global_position.distance_to(burstTarget) > maxBurstRange:
		burstTarget = self.global_position + self.global_position.direction_to(burstTarget) * maxBurstRange
	
func getTargetPos():
	if bursting:
		return burstTarget
	else:
		return target.global_position

func setBursting(value : bool):
	bursting = value
	
func spawnPoundFx():
	var poundFxInstance: Particles2D = groundPoundFx.instance()
	poundFxInstance.global_position = self.global_position #Vector2(self.global_position.x, self.global_position.y + 12)
	poundFxInstance.z_index = -1
	poundFxInstance.emitting = true
	get_tree().current_scene.add_child(poundFxInstance)
	"""poundFxInstance = groundPoundFx.instance()
	poundFxInstance.position = Vector2(50, 0)
	poundFxInstance.z_index = -1
	poundFxInstance.emitting = true
	attackPivot.add_child(poundFxInstance)"""

func canBurst():
	if self.isTargetVisible:
		var distanceToTarget = self.global_position.distance_to(target.global_position)
		return burstTimer.is_stopped() and distanceToTarget <= maxBurstRange and distanceToTarget >= minBurstRange
	else:
		return false

func _hurtbox_area_entered(area: Hitbox):
	._hurtbox_area_entered(area)
	bursting = false
