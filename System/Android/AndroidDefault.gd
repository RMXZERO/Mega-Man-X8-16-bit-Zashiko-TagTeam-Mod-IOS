extends X8TextureButton

func _ready() -> void :
	modulate = Color(0.56, 0.88, 0.12, 1)
	$"../config_button".modulate = Color(1, 1, 1, 1)
	$"../config_button".display()
	$"../exit_without_save".modulate = Color(1, 0, 0, 1)
	$"../exit_with_save".modulate = Color(0.41, 0.79, 1, 1)

func on_press() -> void :
	reset_position()
	modulate = Color(3, 3, 3, 1)
	reset_tween()
	$"../../cancel".play()
	yield(get_tree().create_timer(0.1), "timeout")
	modulate = Color(0.45, 0.88, 0, 1)

func _on_visibility_changed() -> void :
	pass

func reset_position() -> void :
	$"../Key/Pause".position.x = 231
	$"../Key/Pause".position.y = 7
	$"../Key/Jump".position.x = 403
	$"../Key/Jump".position.y = 195
	$"../Key/Dash".position.x = 403
	$"../Key/Dash".position.y = 155
	$"../Key/Fire".position.x = 363
	$"../Key/Fire".position.y = 195
	$"../Key/AltFire".position.x = 363
	$"../Key/AltFire".position.y = 155
	$"../Key/Special".position.x = 363
	$"../Key/Special".position.y = 75
	$"../Key/Switch".position.x = 403
	$"../Key/Switch".position.y = 75
	$"../Key/dashjump".position.x = 363
	$"../Key/dashjump".position.y = 115
	$"../Key/dashaltfire".position.x = 403
	$"../Key/dashaltfire".position.y = 115
	$"../Key/WeaponPrev".position.x = 60
	$"../Key/WeaponPrev".position.y = 19
	$"../Key/WeaponNext".position.x = 402
	$"../Key/WeaponNext".position.y = 19
	$"../Key/joystick".position.x = 91
	$"../Key/joystick".position.y = 166
	$"../Key/weaponround".position.x = 331
	$"../Key/weaponround".position.y = 30




