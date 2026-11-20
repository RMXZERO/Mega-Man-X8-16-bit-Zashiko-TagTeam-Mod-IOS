extends X8OptionButton

export  var legible_name: String
export  var description: String

onready var abilitiy_title = get_parent().get_parent().get_node("Title")
onready var ability_desc = get_parent().get_parent().get_node("Desc")
onready var deactivated_sprite = get_node("deactivated")

func _ready() -> void :
	_on_focus_exited()
	if CharacterManager.extra_saber_03:
		deactivated_sprite.hide()
	else:
		deactivated_sprite.show()

func _on_focus_entered():
	play_sound()
	flash()
	._on_focus_entered()
	abilitiy_title.text = tr(legible_name)
	ability_desc.text = tr(description)

func _on_focus_exited():
	dim()
	._on_focus_exited()
	abilitiy_title.text = ""
	ability_desc.text = ""

func on_press() -> void :
	play_sound()
	toggle_extra_color()
	Savefile.call_deferred("save", Savefile.save_slot)

func process_inputs() -> void :
	pass

func toggle_extra_color() -> void :
	CharacterManager.extra_saber_03 = not CharacterManager.extra_saber_03
	if CharacterManager.extra_saber_03:
		deactivated_sprite.hide()
	else:
		deactivated_sprite.show()
	CharacterManager._save()
