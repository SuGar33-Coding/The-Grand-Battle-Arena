extends Panel

func get_drag_data(_position):
	var consumableSlot = get_parent().name
	if Inventory.getConsumables()[consumableSlot] != null:
		var data = {}
		data.originNode = self
		data.originPanel = "consumable"
		data.originSlotName = consumableSlot
		data.originResource = (Inventory.getConsumables()[consumableSlot] as ItemInstance).resource
		
		var dragTexture = TextureRect.new()
		dragTexture.expand = true
		dragTexture.texture = get_child(0).texture
		dragTexture.rect_size = Vector2(100, 100)
		
		var control = Control.new()
		control.add_child(dragTexture)
		dragTexture.rect_position = -0.5 * dragTexture.rect_size
		set_drag_preview(control)
		
		return data

func can_drop_data(_position, data):
	data.targetSlotName = get_parent().name
	# make sure we can drop item of this type into this slot
	return data.originResource is Consumable

func drop_data(_position, data):
	Inventory.swapItems(data.originPanel, data.originSlotName, 'consumable', data.targetSlotName)
