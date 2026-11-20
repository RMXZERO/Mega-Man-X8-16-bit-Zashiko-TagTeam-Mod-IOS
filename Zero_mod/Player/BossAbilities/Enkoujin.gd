extends BossAbilityZero
class_name EnkoujinAbility


func _ready():
	if active:
		call_deferred("set_ability")

func set_ability():
	if active:
		character.Enkoujin = true

func should_unlock(_collectible: String) -> bool:
	return weapon.collectible in GameManager.collectibles
