class_name Armor extends Item

enum Type {
	Head, Chest, Feet
}

export (Type) var type
# Texture to be used on top of character sprite
export (Texture) var characterTexture
# Percentile reduction from 1 to 100
export (int) var defenseValue
# speedModifier should be negative if it slows, positive if it boosts
export (float) var speedModifier
