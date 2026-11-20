extends Movement
class_name ZeroDesperation

onready var z_slash: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/PlayerZSlash.tscn")

onready var awakenaura: AnimatedSprite = $"../animatedSprite/awakenaura"
onready var animatedSprite: = character.get_node("animatedSprite")
onready var victory: = $victory
onready var use_genmu: Node2D = $"../Special/Genmuzero"

var creator: Node2D

var ready_played: bool = false

var angles = [0, 33, - 33, 90, 44, - 44, 25, - 25, 0, 90, 44, - 25, - 33]
var create_slash: bool = false
var slash_end: bool = false
var desperation_reduce_ammo = 0.075
var desperation_damage = 3
var desperation_speed = 400
var extra_damage = 1
var h = 0

func player_desperation() -> void :
	if not create_slash:
		create_slash = true
		Tools.timer_p(0.075, "create_desperation", self, angles[h])
	
	if use_genmu.current_ammo <= 1:
		slash_end = true
	
	if Input.is_action_pressed("move_up"):
		character.set_vertical_speed( - desperation_speed)
	elif Input.is_action_pressed("move_down"):
		character.set_vertical_speed(desperation_speed)
	else:
		character.set_vertical_speed(0)

	if Input.is_action_pressed("move_left"):
		set_direction_as_pressed_direction()
		character.set_horizontal_speed( - desperation_speed)
	elif Input.is_action_pressed("move_right"):
		set_direction_as_pressed_direction()
		character.set_horizontal_speed(desperation_speed)
	else:
		character.set_horizontal_speed(0)

func create_desperation(degrees: float):
	if animatedSprite.animation == "desperation":
		var slash = z_slash.instance()
		get_tree().current_scene.get_node("Objects").call_deferred("add_child", slash, true)
		slash.damage = desperation_damage * 2 * extra_damage
		slash.damage_to_bosses = desperation_damage * extra_damage
		slash.damage_to_weakness = desperation_damage * 2 * extra_damage
		slash.set_global_position(global_position)
		slash.rotate_degrees(degrees)
		slash.set_creator(creator)
		slash.call_deferred("initialize", get_facing_direction())
		create_desperation2(degrees)

func create_desperation2(degrees: float):
	var slash = z_slash.instance()
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", slash, true)
	slash.set_global_position(global_position)
	slash.rotate_degrees(degrees)
	slash.set_creator(creator)
	slash.hide()
	
	use_genmu.reduce_ammo(desperation_reduce_ammo)
	
	h += 1
	if h > angles.size() - 1:
		h = 0
	create_slash = false

func end_state():
	if animatedSprite.animation == "victory":
		return animatedSprite.frame >= 20 and slash_end
	elif animatedSprite.animation == "desperation":
		if animatedSprite.frame >= 5:
			return character.get_action_pressed("select_special") or Input.is_action_pressed("select_special") or slash_end

func invicible_frames() -> bool:
	animatedSprite.material.set_shader_param("Alpha", 1)
	return animatedSprite.frame >= 0 and animatedSprite.frame < 23

func movement_frames() -> bool:
	return animatedSprite.frame >= 9 and animatedSprite.frame < 23

func _StartCondition() -> bool:
	if not CharacterManager.player_desperation:
		return false
	if not use_genmu.has_ammo_expent(10):
		return false
	if not use_genmu.first_time_casted:
		return false
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		return false
	if character.get_action_pressed("move_down"):
		return false
	if not character.get_action_pressed("move_up"):
		return false
	if not character.is_on_floor():
		return false
	if character.get_action_pressed("select_special"):
		return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	if end_state():
		return true
	if not animatedSprite.animation == "victory" and not animatedSprite.animation == "desperation":
		return true
	return false

func _Setup() -> void :
	ready_played = false
	create_slash = false
	slash_end = false
	animatedSprite.animation = "victory"

func _Update(_delta: float) -> void :
	update_bonus_horizontal_only_conveyor()

	if animatedSprite.animation == "victory":
		set_horizontal_speed(0)
		set_vertical_speed(0)
		if animatedSprite.frame >= 7:
			if not ready_played:
				victory.play()
				ready_played = true
		if animatedSprite.frame >= 20:
			play_animation_once("desperation")
			
	elif animatedSprite.animation == "desperation" and animatedSprite.frame >= 5:
		player_desperation()
		#set_movement_and_direction(400, _delta)
		character.can_eject = false
		use_genmu.stop_recover = true
		awakenaura.hide()
		
	if invicible_frames():
		character.add_invulnerability("Desperation")
	else:
		character.remove_invulnerability("Desperation")

func change_animation_if_falling(_s) -> void :
	pass

func _Interrupt() -> void :
	._Interrupt()
	slash_end = true
	use_genmu.stop_recover = false
	character.can_eject = true
	character.remove_invulnerability("Desperation")
	if not CharacterManager.awakened_zero_armor:
		awakenaura.hide()
	else:
		awakenaura.show()
	if CharacterManager.betazero_activated and CharacterManager.extra_saber_color:
		awakenaura.hide()
