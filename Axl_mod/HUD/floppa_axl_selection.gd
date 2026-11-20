extends X8OptionButton

export  var legible_name: String
export  var description: String

onready var equip: AudioStreamPlayer = $"../../../../../equip"
onready var unequip: AudioStreamPlayer = $"../../../../../unequip"
onready var choice: AudioStreamPlayer = $"../../../../../choice"
onready var icon: TextureRect = $"icon"
onready var name_display: Label = $"../../../../Description/name"
onready var disc_display: Label = $"../../../../Description/disc"
onready var char_name: Label = $"../../../../CharacterName"
onready var floppa_setting: = $"../floppa_axl_setting_holder"
onready var setting: = $"../../axl_setting_holder"

func _ready() -> void :
	_on_focus_exited()
	icon.material.set_shader_param("grayscale", not CharacterManager.floppa_axl_activated)
	check()

func _on_focus_entered() -> void :
	play_sound()
	display_info()
	flash()

func _on_focus_exited() -> void :
	dim()

func on_press() -> void :
	toggle_floppa_axl()
	strong_flash()
	icon.material.set_shader_param("grayscale", not CharacterManager.floppa_axl_activated)

func display_info() -> void :
	name_display.text = tr(legible_name)
	disc_display.text = tr(description)

func process_inputs() -> void :
	pass

func check() -> void :
	if CharacterManager.floppa_axl_activated:
		floppa_setting.show()
		setting.hide()
	else:
		floppa_setting.hide()
		if "track_bullet" in GameManager.collectibles or "share_axl_buff" in GameManager.collectibles or "axl_saber_combo" in GameManager.collectibles:
			setting.show()

func toggle_floppa_axl() -> void :
	CharacterManager.floppa_axl_activated = not CharacterManager.floppa_axl_activated
	if CharacterManager.floppa_axl_activated:
		Tools.timer(0.075, "play", equip)
		$animatedSprite.frame = 0
		floppa_setting.show()
		setting.hide()
	else:
		Tools.timer(0.075, "play", unequip)
		floppa_setting.hide()
		if "track_bullet" in GameManager.collectibles or "share_axl_buff" in GameManager.collectibles or "axl_saber_combo" in GameManager.collectibles:
			setting.show()
