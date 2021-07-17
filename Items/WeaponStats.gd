extends Item

class_name WeaponStats

enum WeaponType {
	MELEE,
	SWORD,
	HEAVY,
	SPEAR,
	RANGED,
	AOE
}

export(WeaponType) var weaponType = WeaponType.MELEE
export(Texture) var weaponTexture
export var damage : int = 10
export var knockbackValue : int = 350
export var radius : float = 15.5
export var length : float = 10.5
# Number of seconds between each attack
export var attackSpeed : float = .7

# SFX
export var quickAttackSFX: AudioStream
export var longAttackSFX: AudioStream

# Ranged Weapon stuff
export var projectileTexture : Texture
export var projectileSpeed : float = 1500
export var projectileRange : float = 350

# AOE Stuff
export var aoeEffect : Resource
export var aoeNumberOfTicks : int = 3
export var aoeLifetime : float = 3.0
# whether or not to instantly do one of the ticks on aoe start
export var instantTick := false
# aoe angle should be < 0 if you don't want it to rotate
#export var aoeAngle : float = -1.0

""""# Secondary stats
export(String) var secondaryName = "Base Sword"
export(WeaponType) var secondaryWeaponType = WeaponType.MELEE
export var secondaryDamage : int = 10
export var secondaryKnockbackValue : int = 350
export var secondaryRadius : float = 15.5
export var secondaryLength : float = 10.5
# Number of seconds between each attack
export var secondaryAttackSpeed : float = .7
export var secondaryTexture : Texture

# SFX
export var secondaryQuickAttackSFX: AudioStream
export var secondaryLongAttackSFX: AudioStream

# Ranged Weapon stuff
export var secondaryProjectileTexture : Texture
export var secondaryProjectileSpeed : float = 1500
export var secondaryProjectileRange : float = 350

# AOE Stuff
export var secondaryAoeNumberOfTicks : int = 3
export var secondaryAoeLifetime : float = 3.0"""
