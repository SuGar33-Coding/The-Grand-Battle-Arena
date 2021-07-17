extends KinematicBody2D

class_name NPC

export var movementResource: Resource
export var baseSpeed: float = 125
export var Acceleration: float = 1000
export var Friction: float = 1000
export var debug: bool = false
export var movementGroup: String = "NPC"
export var pathfindTime = .5
export var movementMaxTime : float = 5.0

signal no_health()

const PERF_THRESHOLD = 500

enum State {
	IDLE,
	CHASE,
	ATTACK,
	STUN
}

var HitEffect = preload("res://FX/HitEffect.tscn")
var floatingText = preload("res://UI/FloatingText.tscn")
var state = State.IDLE
var velocity := Vector2.ZERO
var knockback := Vector2.ZERO
var target: Node2D = null
var closestAlly: NPC = null
var path: PoolVector2Array
var pathIdx := 0
var flag = true
var isTargetVisible := false
var MaxSpeed: float

onready var movement: Movement = movementResource
onready var sprite := $Sprite
onready var stats : Stats = $Stats
onready var hurtbox := $Hurtbox
onready var simpleNav2d: Navigation2D = get_tree().get_current_scene().get_node("SimpleNavigation2D")
onready var nav2d: Navigation2D = get_tree().get_current_scene().get_node("Navigation2D")
onready var pathfindTimer: Timer = $PathfindTimer
onready var movementTimer := $MovementTimer
onready var damagedSfx := $DamagedSFX
onready var collision := $CollisionShape2D

func _ready():
	self.add_to_group(movementGroup)
	hurtbox.connect("area_entered", self, "_hurtbox_area_entered")
	stats.connect("noHealth", self, "_stats_no_health")
	self.MaxSpeed = self.baseSpeed * pow(PlayerStats.dexMoveRatio, stats.dex)
	stats.connect("dexChanged", self, "_dexterity_changed")
	self.Friction = self.Friction * pow(PlayerStats.conFrictionRatio, stats.con)
	
func _physics_process(delta):
	if debug:
		update()
	knockback = knockback.move_toward(Vector2.ZERO, Friction * delta)
	knockback = move_and_slide(knockback)
	
	findClosestAlly()
	
	match state:
		State.IDLE:
			velocity = movement.getIdleVelocity(self, delta)
			if willChase():
				switchToChase()
		State.CHASE:
			if willIdle():
				switchToIdle()
			else:
				lookAtTarget()
				if willAttack():
					switchToAttack()
				if target != null: # TODO: look into this fix some more
					isTargetVisible = sightCheck()
					if nav2d != null and pathfindTimer.is_stopped(): # Last check is to make it not refresh if it doesn't use it
						if self.global_position.distance_to(self.getTargetPos()) > PERF_THRESHOLD:
							path = simpleNav2d.get_simple_path(simpleNav2d.get_closest_point(global_position), simpleNav2d.get_closest_point(self.getTargetPos()), false)
						else:
							path = nav2d.get_simple_path(nav2d.get_closest_point(global_position), nav2d.get_closest_point(self.getTargetPos()), false)
						pathfindTimer.start(pathfindTime)
						pathIdx = 0
					velocity = movement.getMovementVelocity(self, self.getTargetPos(), delta)
		State.ATTACK:
			velocity = movement.getIdleVelocity(self, delta)
		State.STUN:
			velocity = movement.getIdleVelocity(self, delta)
	
	if willFlipLeft():
		flipLeft()
		
	elif willFlipRight():
		flipRight()
		
	velocity = move_and_slide(velocity)

func _draw():
	if debug:
		# Draw some debug info
		var color = Color(1,0,0)
		draw_line(Vector2.ZERO, velocity, color)
		draw_line(velocity, velocity - velocity.rotated(deg2rad(-30)) * 0.1, color)
		draw_line(velocity, velocity - velocity.rotated(deg2rad(30)) * 0.1, color)
		
		var label = Label.new()
		var font = label.get_font("")
		draw_string(font, Vector2(-15,-25), State.keys()[state], Color(1,1,1))
		
		if path != null and path.size() > 0:
			var from = path[0] - global_position
			var to
			for pos in path:
				to = pos - global_position
				draw_line(from, to, Color(0,0,1))
				from = to
	
func lookAtTarget():
	pass
	
func willIdle() -> bool:
	return false
	
func willChase() -> bool:
	return false
	
func willAttack() -> bool:
	return false
	
func willStun() -> bool:
	return true
	
func switchToIdle():
	self.state = State.IDLE
	
func switchToChase():
	self.state = State.CHASE
	
func switchToAttack():
	self.state = State.ATTACK
	
func switchToStun():
	self.state = State.STUN
	
func getTargetPos():
	return target.global_position
	
func willFlipLeft() -> bool:
	return velocity.x < 0
	
func willFlipRight() -> bool:
	return velocity.x > 0
	
func flipLeft():
	pass
	
func flipRight():
	pass
	
func findClosestAlly():
	pass
	
# Returns whether NPC can see target or not
func sightCheck() -> bool:
	if target != null:
		var spaceState := get_world_2d().direct_space_state
		# Cast ray from collision box since that is the thing that needs to be routed
		var rayCollision := spaceState.intersect_ray(collision.global_position, target.global_position, [self], collision_mask)
		
		return rayCollision.empty()
	
	return false
	
func _hurtbox_area_entered(area : Hitbox):
	var damageAmount = max(1, int(area.damage * (1 - (stats.armorValue/100.0))))
	
	var text = floatingText.instance()
	text.amount = damageAmount
	add_child(text)
	
	var hitEffect = HitEffect.instance()
	hitEffect.init(area.getSourcePos())
	add_child(hitEffect)
	
	if area.fromPlayer:
		PlayerStats.currentXP += min(stats.health, damageAmount)
	
	if willStun():
		switchToStun()
	stats.health -= damageAmount
	knockback = area.getKnockbackVector(self.global_position)
	
	damagedSfx.play()

func _dexterity_changed(value):
	self.MaxSpeed = self.baseSpeed * pow(PlayerStats.dexRatio, value)

func _stats_no_health():
	emit_signal("no_health")
	queue_free()
