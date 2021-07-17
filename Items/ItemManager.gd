extends Node

# Insatnce an item based on an Item resource and return its NodePath in the
# ItemManager
func createItem(resourcePath: String):
	var resource: Item = load(resourcePath)
	var item := ItemInstance.new()
	item.resource = resource
	
	add_child(item)
	
	return item.get_path()
