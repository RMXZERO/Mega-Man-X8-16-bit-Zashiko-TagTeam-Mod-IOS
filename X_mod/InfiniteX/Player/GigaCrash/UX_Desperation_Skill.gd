extends Fall

onready var desperation: PackedScene = preload("res://X_mod/InfiniteX/Player/Projectiles/Player_Desperation.tscn")
var creator: Node2D

var ending_saber_state: bool = true
onready var arm_cannon = character.get_node("Shot")

onready var giga_attack = $"../Shot/NovaStrike"
onready var animatedSprite = character.get_node("animatedSprite")
onready var sfx_sound: AudioStreamPlayer = $sfx
onready var victory_sound: AudioStreamPlayer2D = $victory

var jumped: bool = false

var genmu_ready_played: bool = false
var angles = [0, 45, 90, 135, 180, 225, 270, 315]
var create_slash: bool = false
var slash_end: bool = false
var desperation_reduce_ammo = 1.5
var desperation_damage = 16
var desperation_speed = 400
var h = 0

func _ready():
	animatedSprite.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished() -> void :
	ending_saber_state = true

func end_state():
	return ending_saber_state

func player_desperation() -> void :
	if not create_slash:
		create_slash = true
		Tools.timer_p(0.075, "create_desperation", self, angles[h])
		
	if giga_attack.current_ammo <= 1:
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
	sfx_sound.play()
	var instance = desperation.instance()
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.damage = desperation_damage
	instance.damage_to_bosses = desperation_damage
	instance.damage_to_weakness = desperation_damage
	
	if degrees == 0:
		instance.set_vertical_speed(desperation_speed * 2)
	if degrees == 45:
		instance.set_vertical_speed(desperation_speed * 2)
		instance.set_horizontal_speed(- desperation_speed * 2)
	if degrees == 90:
		instance.set_horizontal_speed(- desperation_speed * 2)
	if degrees == 135:
		instance.set_vertical_speed(- desperation_speed * 2)
		instance.set_horizontal_speed(- desperation_speed * 2)
	if degrees == 180:
		instance.set_vertical_speed(- desperation_speed * 2)
	if degrees == 225:
		instance.set_vertical_speed(- desperation_speed * 2)
		instance.set_horizontal_speed(desperation_speed * 2)
	if degrees == 270:
		instance.set_horizontal_speed(desperation_speed * 2)
	if degrees == 315:
		instance.set_vertical_speed(desperation_speed * 2)
		instance.set_horizontal_speed(desperation_speed * 2)
	instance.rotate_degrees(degrees)
	
	instance.set_global_position(global_position)
	instance.rotate_degrees(degrees)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())
	
	giga_attack.reduce_ammo(desperation_reduce_ammo)
	h += 1
	if h > angles.size() - 1:
		h = 0
	create_slash = false

func _StartCondition() -> bool:
	if not CharacterManager.player_desperation:
		if not CharacterManager.infinite_x_activated:
			return false
	if not character.is_on_floor():
		return false
	if not character.get_action_pressed("move_up"):
		return false
	if character.get_action_pressed("select_special") and character.get_action_pressed("move_up"):
		return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	if animatedSprite.animation == "empty" and character.get_action_pressed("select_special"):
		return true
	if animatedSprite.animation == "empty" and Input.is_action_pressed("select_special"):
		return true
	if slash_end:
		return true
	return false

func _Setup() -> void :
	jumped = false
	ending_saber_state = false
	genmu_ready_played = false
	create_slash = false
	slash_end = false
	if character.is_on_floor():
		animatedSprite.animation = "victory"

func _Update(_delta: float) -> void :
	character.add_invulnerability("Desperation")

	if animatedSprite.animation == "victory":
		set_horizontal_speed(0)
		set_vertical_speed(0)
		if animatedSprite.frame >= 0:
			if not genmu_ready_played:
				victory_sound.play()
				genmu_ready_played = true
		if animatedSprite.frame >= 20:
			play_animation_once("empty")
			
	elif animatedSprite.animation == "empty" and animatedSprite.frame >= 0:
		player_desperation()
		character.can_eject = false
		giga_attack.stop_recover = true

func change_animation_if_falling(_s) -> void :
	if not character.is_on_floor():
		animatedSprite.animation = "fall"
	else:
		animatedSprite.animation = "recover"

func _Interrupt():
	character.can_eject = true
	giga_attack.stop_recover = false
	character.remove_invulnerability("Desperation")
	if not character.is_on_floor():
		animatedSprite.animation = "fall"
	else:
		animatedSprite.animation = "recover"

func Initialize() -> void :
	executing = true
	timer = 0
	last_time_used = get_time()
	character.executing_moves.append(self)
	emit_signal("executed")
	play_sound_on_initialize()
	play_animation_on_initialize()

func BeforeEveryFrame(_delta: float) -> void :
	pass
