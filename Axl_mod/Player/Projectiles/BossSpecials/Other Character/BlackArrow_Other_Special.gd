extends Node2D

onready var character: = get_parent().get_parent()
onready var special_afterimages: = $afterImages
onready var special_afterimages2: = $afterImages2
onready var sfx: = $sfx

func _ready() -> void :
	Event.listen("axl_special_ability", self, "ability_parts")

func ability_parts(ability_name: String):
	if not CharacterManager.share_axl_buff or not "share_axl_buff" in GameManager.collectibles:
		special_afterimages.deactivate()
		special_afterimages2.deactivate()
		character.remove_invulnerability("blackarrow_ability")
		character.alpha_alway_1 = false
		return
	if ability_name == "blackarrow":
		special_afterimages.activate()
		special_afterimages2.activate()
		character.add_invulnerability("blackarrow_ability")
		character.alpha_alway_1 = true
	else:
		special_afterimages.deactivate()
		special_afterimages2.deactivate()
		character.remove_invulnerability("blackarrow_ability")
		character.alpha_alway_1 = false

