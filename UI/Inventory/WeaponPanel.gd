extends InventoryPanel 

func _ready():
	Inventory.connect("inventory_changed", self, "_updateDisplay")

	for slot in Inventory.getWeapons().keys():
		if Inventory.getWeapons()[slot] != null:
			# grab item icon and replace the getConsumables icon with it
			var iconTexture = (Inventory.getWeapons()[slot] as ItemInstance).getTexture()
			(gridContainer.get_node(slot).get_child(0).get_child(0) as TextureRect).texture = iconTexture


func _updateDisplay(_from_panel, _to_panel):
	var consumables := Inventory.getWeapons()
	for slot in consumables.keys():
		var slotIcon: TextureRect = gridContainer.get_node(slot).get_child(0).get_child(0)
		if consumables[slot] != null:
			# if there's an item, update the slot with that sprite
			slotIcon.texture = (consumables[slot] as ItemInstance).getTexture()
		else:
			# otherwise replace with default texture
			slotIcon.texture = null
