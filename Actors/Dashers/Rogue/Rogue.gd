extends Fighter

var dashCloudFx = preload("res://FX/DashCloud.tscn")

export(int) var maxBurstRange = 125
export(int) var minBurstRange = 20
export(float) var burstTimeMax = 9
export(float) var burstTimeMin = 5
export(float) var BurstAcceleration = 10000
export(float) var BaseBurstSpeed = 600 
export(float) var overDashAmount = 30
export(float) var stopRange = 10

var collisionChecker = preload("res://Actors/Zones/CollisionCheck.tscn")
var groundPoundFx = preload("res://FX/GroundPoundFx.tscn")
var bursting : bool = false setget setBursting
var BurstSpeed : float = 5000
var poundRange : float
var burstTarget : Vector2 = Vector2.ZERO

onready var burstTimer := $BurstTimer

# TODO add specific burst target
func _physics_process(_delta):
	if bursting and target and state == State.CHASE:
		if self.global_position.distance_to(burstTarget) < stopRange:
			# If we want them to have to wind up first, just play wind up here
			animationPlayer.play("MeleeAttack")
			stopBurstSpeed()

# When in range I want to stop and charge up :: Use attack state to stop us
# Then I want to reenter chase to start moving toward target, but prevent reenteringa ttack state :: use boolean
# When I land I want to set a timer between bursts and allow to enter normal attack state
func switchToAttack():
	if bursting:
		state = State.ATTACK
		animationPlayer.playback_speed = 1
		animationPlayer.play("Dash")
		var animLength = animationPlayer.current_animation_length
		BurstSpeed = BaseBurstSpeed
		burstTimer.start(rand_range(burstTimeMin, burstTimeMax)+animLength)
		#self.switchToChase()
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

func slowBurstSpeed():
	BurstSpeed *= .1
	
func stopBurstSpeed():
	BurstSpeed = 0
	
func setBurstTargetPos():
	if target:
		burstTarget = target.global_position
		if self.global_position.distance_to(burstTarget) > maxBurstRange:
			burstTarget = self.global_position + self.global_position.direction_to(burstTarget) * maxBurstRange
	else:
		burstTarget = self.global_position
	
	burstTarget = burstTarget + self.global_position.direction_to(burstTarget) * overDashAmount
	
func getTargetPos():
	if bursting:
		return burstTarget
	else:
		return target.global_position

func setBursting(value : bool):
	bursting = value
	
func spawnDashFx():
	var dashCloudFxInstance: Particles2D = dashCloudFx.instance()
	dashCloudFxInstance.global_position = Vector2(self.global_position.x, self.global_position.y + 12)
	dashCloudFxInstance.z_index = -1
	dashCloudFxInstance.emitting = true
	get_tree().current_scene.add_child(dashCloudFxInstance)

func canBurst():
	if self.isTargetVisible:
		var distanceToTarget = self.global_position.distance_to(target.global_position)
		return burstTimer.is_stopped() and distanceToTarget <= maxBurstRange and distanceToTarget >= minBurstRange
	else:
		return false

func _hurtbox_area_entered(area: Hitbox):
	._hurtbox_area_entered(area)
	bursting = false
