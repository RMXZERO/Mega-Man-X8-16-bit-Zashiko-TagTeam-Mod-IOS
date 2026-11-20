extends BossAbilityZero
class_name YoudantotsuAbility


func _ready():
	if active:
		call_deferred("set_ability")

func set_ability():
	if active:
		character.Youdantotsu = true


func should_unlock(_collectible: String) -> bool:
	return weapon.collectible in GameManager.collectibles
