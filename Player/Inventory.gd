extends Node

signal inventory_changed(from_panel, to_panel)
signal coins_changed(total_coins)

# TODO: Do we want different coin types?
var _inventory := {
	"bag": {
		"0": null,
		"1": null,
		"2": null,
		"3": null,
	},
	"armor": {
		Armor.Type.Head: null,
		Armor.Type.Chest: null,
		Armor.Type.Feet: null
	},
	"consumable": {
		"0": null,
		"1": null,
		"2": null,
		"3": null,
	},
	"weapon": {
		"0": null,
		"1": null
	},
	"coins": 0
}

func resetInventory():
	for key in _inventory.keys():
		if key == "coins":
			_inventory[key] = 0
		else:
			for lowerKey in _inventory[key].keys():
				_inventory[key][lowerKey] = null

func getBag() -> Dictionary:
	return _inventory.bag


func getArmor() -> Dictionary:
	return _inventory.armor

func getConsumables() -> Dictionary:
	return _inventory.consumable

func getWeapons() -> Dictionary:
	return _inventory.weapon


func isBagFull():
	for slot in _inventory.bag.keys():
		if _inventory.bag[slot] == null:
			return false
	return true

func addItemToBag(item: ItemInstance):
	for slot in _inventory.bag.keys():
		if _inventory.bag[slot] == null:
			_inventory.bag[slot] = item
			emit_signal("inventory_changed", "bag", "bag")
			break

func addCoins(numCoins: int):
	_inventory["coins"] += numCoins
	emit_signal("coins_changed", _inventory["coins"])

func swapItems(location1, slot1, location2, slot2):
	# do da swappe
	var item1 = _inventory[location1][slot1]
	_inventory[location1][slot1] = _inventory[location2][slot2]
	_inventory[location2][slot2] = item1
	emit_signal("inventory_changed", location1, location2)
