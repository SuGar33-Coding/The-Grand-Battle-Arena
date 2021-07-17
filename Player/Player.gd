extends KinematicBody2D

var dirtFx = preload("res://FX/DirtSpread.tscn")
var dashCloudFx = preload("res://FX/DashCloud.tscn")

export var Acceleration: float = 1500
export var startingFriction: float = 750
export var baseDashSpeed := 500
export var dashDelay := .75

# TODO: Probably move dash speed to player stats
var velocity := Vector2.ZERO
var knockback := Vector2.ZERO
var dashVector := Vector2.ZERO
var dashSpeed := 500
var HitEffect = preload("res://FX/HitEffect.tscn")
var floatingText = preload("res://UI/FloatingText.tscn")
var Friction: float
var armorValue : int = 0

onready var stats = get_node("/root/PlayerStats")
onready var inventory = get_node("/root/Inventory")
onready var sprite := $Sprite
onready var headSprite := $Sprite/HeadSprite
onready var chestSprite := $Sprite/ChestSprite
onready var legSprite := $Sprite/LegSprite
onready var shadowSprite := $ShadowSprite
onready var attackPivot := $AttackPivot
onready var hurtbox := $Hurtbox
onready var camera := $MainCamera
onready var damagedPlayer := $DamagedPlayer
onready var dashTimer := $DashTimer
onready var movementAnimation := $MovementAnimation
onready var animationPlayer := $AnimationPlayer
onready var footstep1 := $Footstep1
onready var footstep2 := $Footstep2


func _ready():
	Engine.set_target_fps(Engine.get_iterations_per_second())

	PlayerStats.strength = 0
	PlayerStats.con = 0
	PlayerStats.dex = 0
	PlayerStats.health = PlayerStats.maxHealth
	PlayerStats.playerLevel = 1
	PlayerStats.currentXP = 0

	Friction = startingFriction
	stats.connect("noHealth", self, "_playerstats_no_health")
	stats.connect("playerLevelChanged", self, "_player_level_changed")
	hurtbox.connect("area_entered", self, "_hurtbox_area_entered")
	$AttackPivot/ComboTimer.connect("timeout", self, "_combo_finished")
	inventory.connect("inventory_changed", self, "_inventory_changed")
	
	sprite.material.set_shader_param("banner_color", stats.playerColor)
	
	dashSpeed = baseDashSpeed
	checkArmorStats()


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, Friction * delta)
	knockback = move_and_slide(knockback)

	dashVector = dashVector.move_toward(Vector2.ZERO, Acceleration * delta)
	dashVector = move_and_slide(dashVector)

	var inputVector = Vector2.ZERO

	inputVector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	inputVector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	inputVector = inputVector.normalized()

	if Input.is_action_just_pressed("dash") and dashTimer.is_stopped():
		# Cannot dash while aiming
		if not attackPivot.chargingRanged:
			dashVector = inputVector * dashSpeed
			dashTimer.start(dashDelay * pow(PlayerStats.dexDashRatio, PlayerStats.dex))
			movementAnimation.play("Dashing")
			PlayerStats.resetMaxSpeed()
	elif inputVector != Vector2.ZERO:
		velocity = velocity.move_toward(inputVector * stats.maxSpeed, Acceleration * delta)

		if ! movementAnimation.is_playing():
			movementAnimation.play("Walking")
	else:
		movementAnimation.play("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, Friction * delta)

	# Make sprite turn towards mouse
	var mousePos = self.get_global_mouse_position()
	if mousePos.x < global_position.x:
		sprite.flip_h = true
		headSprite.flip_h = true
		chestSprite.flip_h = true
		legSprite.flip_h = true
		shadowSprite.position.x = .5
		attackPivot.scale.y = -1
	else:
		sprite.flip_h = false
		headSprite.flip_h = false
		chestSprite.flip_h = false
		legSprite.flip_h = false
		shadowSprite.position.x = 1.25
		attackPivot.scale.y = 1

	attackPivot.look_at(mousePos)

	velocity = move_and_slide(velocity)


func spawnDirtFx(initVelocity = 50, lifetime = 0.4):
	var dirtFxInstance: Particles2D = dirtFx.instance()
	var newMat: ParticlesMaterial = dirtFxInstance.process_material
	newMat.initial_velocity = initVelocity
	dirtFxInstance.material = newMat
	dirtFxInstance.lifetime = lifetime
	dirtFxInstance.global_position = Vector2(self.global_position.x, self.global_position.y + 12)
	# TODO: Probably want to avoid using negative z values, maybe scale everything up?
	dirtFxInstance.z_index = -2
	dirtFxInstance.emitting = true
	get_tree().current_scene.add_child(dirtFxInstance)


func spawnDashFx():
	var dashCloudFxInstance: Particles2D = dashCloudFx.instance()
	dashCloudFxInstance.global_position = Vector2(
		self.global_position.x, self.global_position.y + 12
	)
	dashCloudFxInstance.z_index = -1
	dashCloudFxInstance.emitting = true
	get_tree().current_scene.add_child(dashCloudFxInstance)


func playFootstep(foot = 1):
	match foot:
		1:
			footstep1.play()
		2:
			footstep2.play()

func checkArmorStats():
	armorValue = 0
	stats.speedModifier = 1.0
	var armorDict = inventory.getArmor()
	for key in armorDict.keys():
		var itemInstance = armorDict.get(key)
		if is_instance_valid(itemInstance):
			var piece : Armor = itemInstance.resource as Armor
			match piece.type:
				Armor.Type.Head:
					headSprite.texture = piece.characterTexture
				Armor.Type.Chest:
					chestSprite.texture = piece.characterTexture
				Armor.Type.Feet:
					legSprite.texture = piece.characterTexture
			armorValue += piece.defenseValue
			stats.speedModifier += piece.speedModifier
		else:
			match key:
				Armor.Type.Head:
					headSprite.texture = null
				Armor.Type.Chest:
					chestSprite.texture = null
				Armor.Type.Feet:
					legSprite.texture = null
	 
	stats.resetMaxSpeed()
	# Speed modifier affects dash speed half as much
	dashSpeed = baseDashSpeed * (1.0 + ((stats.speedModifier - 1.0)/2.0))


func _player_level_changed(_newPlayerLevel):
	attackPivot.userStr = PlayerStats.strength
	self.Friction = self.startingFriction * pow(PlayerStats.conFrictionRatio, PlayerStats.con)


func _hurtbox_area_entered(area: Hitbox):
	var damageAmount = max(1, int(area.damage * (1 - (armorValue/100.0))))
	
	var text = floatingText.instance()
	text.amount = damageAmount
	add_child(text)

	var hitEffect = HitEffect.instance()
	hitEffect.init(area.getSourcePos())
	add_child(hitEffect)
	

	stats.health -= damageAmount
	stats.currentXP += damageAmount
	camera.add_trauma(area.knockbackValue / 1000.0)
	knockback = area.getKnockbackVector(self.global_position)
	damagedPlayer.play("Damaged")
	hurtbox.startInvincibility(PlayerStats.invulnTimer)


func _playerstats_no_health():
	# When Player dies, return to main menu TODO: Change this
	#get_tree().change_scene("res://UI/StartMenu/StartMenu.tscn")
	self.remove_child(camera)
	camera.set_deferred("global_position", self.global_position)
	camera.add_trauma(2)
	var world = get_tree().current_scene
	world.add_child(camera)
	world.playerDied()
	self.queue_free()

func _inventory_changed(from_panel, to_panel):
	if(from_panel == "armor" or to_panel == "armor"):
		checkArmorStats()

func _melee_quick():
	animationPlayer.play("MeleeAttack")
	PlayerStats.maxSpeed *= .65


func _meleeLong():
	animationPlayer.play("Stab")
	_combo_finished()


func _parry():
	animationPlayer.play("Parry")
	PlayerStats.maxSpeed *= .65

func _combo_finished():
	PlayerStats.resetMaxSpeed()
