extends Panel

func get_drag_data(_position):
	var weaponSlot = get_parent().name
	if Inventory.getWeapons()[weaponSlot] != null:
		var data = {}
		data.originNode = self
		data.originPanel = "weapon"
		data.originSlotName = weaponSlot
		data.originResource = (Inventory.getWeapons()[weaponSlot] as ItemInstance).resource
		
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
	return data.originResource is WeaponStats

func drop_data(_position, data):
	Inventory.swapItems(data.originPanel, data.originSlotName, 'weapon', data.targetSlotName)
