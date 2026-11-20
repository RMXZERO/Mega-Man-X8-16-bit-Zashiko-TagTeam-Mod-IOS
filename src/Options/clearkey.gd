extends X8TextureButton
class_name ClearkeyButton

export  var post_confirm: String

var game_data = {}

export  var default_label: String = "CLEAR KEY CONFIRM"
export  var confirmation: String = "PRESS AGAIN TO CONFIRM"

onready var text: Label = $text

var times_pressed: int = 0
var flashed: bool = false


func _ready() -> void :
	text.text = tr(default_label)
	Event.connect("translation_updated", self, "on_update")

func on_update() -> void :
	text.text = tr(default_label)
	pass

func on_press() -> void :
	times_pressed += 1
	if times_pressed == 1:
		if not flashed:
			strong_flash()
			flashed = true
			menu.play_equip_sound()
		text.text = tr(confirmation)
	if times_pressed >= 2:
		menu.play_cancel_sound()
		strong_flash()
		yield(get_tree().create_timer(0.1), "timeout")
		action()

func action() -> void :
	Savefile.save(Savefile.save_slot)
	reset_tween()
	InputMap.load_from_globals()
	InputManager.modified_keys.clear()
	GameManager.go_to_intro()

func _on_focus_exited() -> void :
	._on_focus_exited()
	flashed = false
	times_pressed = 0
	text.text = tr(default_label)
