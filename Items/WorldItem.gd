extends KinematicBody2D

export var baseSpeed = 100
export var Friction = 75

# TODO: Only using this as export for testing purposes
var item : ItemInstance
var itemResource : Item
var playerInZone := false
var mouseInZone := false
var highlightShader := preload("res://FX/HighlightFX.shader")
var LabelContainer := preload("res://UI/TooltipLabel.tscn")
var velocity := Vector2.ZERO
var movement := false
var movementDir := Vector2.ZERO

onready var itemSprite = $ItemSprite
onready var tooltipPanel = $PanelContainer
onready var vboxContainer = $PanelContainer/VBoxContainer
onready var nameLabel = $PanelContainer/VBoxContainer/NameContainer/Label
onready var valueLabel = $PanelContainer/VBoxContainer/ValueContainer/Label
onready var animationPlayer = $AnimationPlayer
onready var pickupMessage = $PickupMessage

func init(itemInstance: ItemInstance, shouldMove := false):
	item = itemInstance
	itemResource = item.resource
	movement = shouldMove
	if movement:
		movementDir = Vector2(rand_range(-1, 1), rand_range(-1, 1))
		movementDir = movementDir.normalized()


# TODO: Adjust starting height and animation height based on sprite size
func _ready():
	tooltipPanel.visible = false
	pickupMessage.visible = false
	itemSprite.texture = item.getTexture()
	nameLabel.text = item.itemName
	valueLabel.text = str(itemResource.value)
	itemSprite.material = ShaderMaterial.new()
	
	velocity = baseSpeed * movementDir
	
	if itemResource is Armor:
		addNewLabel("Type:   " + Armor.Type.keys()[itemResource.type])
		addNewLabel("DEF:   " + str(itemResource.defenseValue))
		addNewLabel("SPD:   " + str(itemResource.speedModifier))
	elif itemResource is Consumable:
		pass
	elif itemResource is WeaponStats:
		itemResource = itemResource as WeaponStats
		addNewLabel("Type:   " + WeaponStats.WeaponType.keys()[itemResource.weaponType])
		addNewLabel("DMG:   " + str(itemResource.damage))
		addNewLabel("ATK:   " + str(stepify((1.0/itemResource.attackSpeed), .01)) + "/s")

func _physics_process(delta):
	if(playerInZone and mouseInZone):
		if Input.is_action_just_pressed("use"):
			Inventory.addItemToBag(item)
			queue_free()
		else:
			pickupMessage.visible = true
	elif pickupMessage.visible == true:
		pickupMessage.visible = false
	
	if(mouseInZone and Input.is_action_pressed("info")):
		tooltipPanel.visible = true
		pickupMessage.visible = false
	elif tooltipPanel.visible == true:
		tooltipPanel.visible = false
	
	if movement:
		velocity = velocity.move_toward(Vector2.ZERO, Friction * delta)
		
	velocity = move_and_slide(velocity)

func addNewLabel(labelString : String):
	var newContainer = LabelContainer.instance()
	var label = newContainer.get_child(0)
	label.text = labelString
	vboxContainer.add_child(newContainer)

func playFloat():
	animationPlayer.play("Float")

func _on_MouseArea_mouse_entered():
	mouseInZone = true
	if playerInZone:
		(itemSprite.material as ShaderMaterial).shader = highlightShader
		pickupMessage.visible = true

func _on_MouseArea_mouse_exited():
	mouseInZone = false
	(itemSprite.material as ShaderMaterial).shader = null
	pickupMessage.visible = false

func _on_PlayerCollision_body_entered(body):
	playerInZone = true
	if mouseInZone:
		(itemSprite.material as ShaderMaterial).shader = highlightShader
		pickupMessage.visible = true

func _on_PlayerCollision_body_exited(body):
	playerInZone = false
	(itemSprite.material as ShaderMaterial).shader = null
	pickupMessage.visible = false

