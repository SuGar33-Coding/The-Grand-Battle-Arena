extends KinematicBody2D

export var baseSpeed = 75
export var maxSpeed = 150
export var Friction = 125
export var Acceleration = 60

const SignalScene = preload("res://FX/AttackSignal.tscn")

var playerInZone := false
var velocity := Vector2.ZERO
var movementDir := Vector2.ZERO
var playerBody : KinematicBody2D = null

onready var inventory : Inventory = get_node("/root/Inventory")
onready var itemSprite = $ItemSprite
onready var animationPlayer = $AnimationPlayer


# TODO: Adjust starting height and animation height based on sprite size
func _ready():
	movementDir = Vector2(rand_range(-1, 1), rand_range(-1, 1))
	movementDir = movementDir.normalized()
	
	velocity = baseSpeed * movementDir

func _physics_process(delta):
	
	if playerInZone:
		velocity = velocity.move_toward(self.global_position.direction_to(playerBody.global_position) * maxSpeed, Acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, Friction * delta)
	
	velocity = move_and_slide(velocity)

func playFloat():
	animationPlayer.play("Float")

func addCoinToPlayer():
	var ping : Particles2D = SignalScene.instance()
	ping.global_position = itemSprite.global_position
	var world = get_tree().get_current_scene()
	world.add_child(ping)
	ping.set_deferred("emitting", true)
	
	inventory.addCoins(1)
	queue_free()

func killCoin():
	queue_free()

func _on_PlayerCollision_body_entered(body):
	playerInZone = true
	playerBody = body

func _on_PlayerCollision_body_exited(_body):
	playerInZone = false

func _on_PickupZone_body_entered(_body):
	animationPlayer.play("Pickup")

func _on_PickupZone_body_exited(_body):
	pass # Replace with function body.
	# Something went wrong
