extends X8TextureButton

onready var megaman: TextureRect = $"../MegaMan"
onready var rockman: TextureRect = $"../RockMan"

func _ready() -> void :
	var _s = get_parent().connect("visibility_changed", self, "_on_visibility_changed")
	set_tltle()

func set_tltle() -> void :
	if rockman:
		rockman.visible = false
	if megaman:
		megaman.visible = false
	if Configurations.exists("TitleType"):
		if Configurations.get("TitleType"):
			if megaman:
				megaman.visible = true
		else:
			if rockman:
				rockman.visible = true

func on_press() -> void :
	save_position()
	Event.emit_signal("touchcontrol")
	CharacterManager._save()
	modulate = Color(3, 3, 3, 1)
	reset_tween()
	tween.tween_property(self, "modulate", Color.white, 0.35)
	$"../../equip".play()
	yield(get_tree().create_timer(0.1), "timeout")
	GameManager.go_to_intro()

func _on_visibility_changed() -> void :
	set_tltle()
	if get_parent().visible:
		call_deferred("grab_focus")

func save_position() -> void :
	CharacterManager.pause_position_x = $"../Key/Pause".position.x * 10 - 190
	CharacterManager.pause_position_y = $"../Key/Pause".position.y * 10 - 70
	CharacterManager.jump_position_x = $"../Key/Jump".position.x * 10 - 190
	CharacterManager.jump_position_y = $"../Key/Jump".position.y * 10 - 190
	CharacterManager.dash_position_x = $"../Key/Dash".position.x * 10 - 190
	CharacterManager.dash_position_y = $"../Key/Dash".position.y * 10 - 190
	CharacterManager.fire_position_x = $"../Key/Fire".position.x * 10 - 190
	CharacterManager.fire_position_y = $"../Key/Fire".position.y * 10 - 190
	CharacterManager.alt_fire_position_x = $"../Key/AltFire".position.x * 10 - 190
	CharacterManager.alt_fire_position_y = $"../Key/AltFire".position.y * 10 - 190
	CharacterManager.special_position_x = $"../Key/Special".position.x * 10 - 190
	CharacterManager.special_position_y = $"../Key/Special".position.y * 10 - 190
	CharacterManager.switch_position_x = $"../Key/Switch".position.x * 10 - 190
	CharacterManager.switch_position_y = $"../Key/Switch".position.y * 10 - 190
	CharacterManager.dash_jump_position_x = $"../Key/dashjump".position.x * 10 - 190
	CharacterManager.dash_jump_position_y = $"../Key/dashjump".position.y * 10 - 190
	CharacterManager.dash_fire_position_x = $"../Key/dashaltfire".position.x * 10 - 190
	CharacterManager.dash_fire_position_y = $"../Key/dashaltfire".position.y * 10 - 190
	CharacterManager.weapon_left_position_x = $"../Key/WeaponPrev".position.x * 10 - 280
	CharacterManager.weapon_left_position_y = $"../Key/WeaponPrev".position.y * 10 - 190
	CharacterManager.weapon_right_position_x = $"../Key/WeaponNext".position.x * 10 - 280
	CharacterManager.weapon_right_position_y = $"../Key/WeaponNext".position.y * 10 - 190
	CharacterManager.joystick_position_x = $"../Key/joystick".position.x * 10
	CharacterManager.joystick_position_y = $"../Key/joystick".position.y * 10
	CharacterManager.weaponround_position_x = $"../Key/weaponround".position.x * 10
	CharacterManager.weaponround_position_y = $"../Key/weaponround".position.y * 10






