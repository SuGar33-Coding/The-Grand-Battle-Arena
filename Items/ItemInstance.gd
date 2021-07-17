class_name ItemInstance extends Node2D

var resource: Item setget _setResource
var sprite := Sprite.new()
var itemName: String

func _ready():
	add_child(sprite)

func getTexture():
	return sprite.texture

# update this instance whenever the resource gets changed
func _setResource(newResource):
	resource = newResource
	itemName = resource.name
	sprite.texture = resource.texture
