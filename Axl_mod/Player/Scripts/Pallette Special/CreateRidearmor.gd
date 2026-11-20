extends Movement

const ridearmor = preload("res://src/Actors/Props/RideArmor/RideArmor.tscn")
onready var animatedSprite: = character.get_node("animatedSprite")
onready var victory: = $victory
onready var ridearmor_ammo: Node2D = $"../Special/RideArmor"

var creator: Node2D

var victory_played: bool = false
var create_ridearmor: bool = false
var ridearmor_intro: bool = false

func _ready() -> void :
	pass

func play_sfx() -> void :
	if not victory_played:
		victory_played = true
		victory.play()
	if $"../animatedSprite/Ridearmor".frame >= 15:
		if ridearmor_intro:
			if not create_ridearmor:
				create_ridearmor = true
				ridearmor_ammo.reduce_ammo(60)
				on_spawn_ridearm_pressed()
	if animatedSprite.frame >= 10:
		if not ridearmor_intro:
			ridearmor_intro = true
			$"../animatedSprite/Ridearmor".frame = 0

func on_spawn_ridearm_pressed() -> void:
	var instance = ridearmor.instance()
	instance.name = "RideArmorPallette"
	instance.song_intro = load("")
	instance.song_loop = load("")
	instance.song_remix_intro = load("")
	instance.song_remix_loop = load("")
	get_tree().current_scene.add_child(instance,true)
	var armor_pos = GameManager.get_player_position()
	armor_pos.y -= 16
	instance.set_position(armor_pos)

func end_state() -> bool:
	return animatedSprite.frame >= 19

func invicible_frames() -> bool:
	animatedSprite.material.set_shader_param("Alpha", 1)
	return animatedSprite.frame >= 0 and animatedSprite.frame <= 11

func _StartCondition() -> bool:
	if not ridearmor_ammo.has_ammo_expent(60):
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
	if not animatedSprite.animation == "beam_equip":
		return true
	return false

func _Setup() -> void :
	victory_played = false
	create_ridearmor = false
	ridearmor_intro = false
	update_bonus_horizontal_only_conveyor()
	animatedSprite.animation = "beam_equip"
	animatedSprite.frame = 1

func _Update(_delta: float) -> void :
	play_sfx()
	update_bonus_horizontal_only_conveyor()
	if invicible_frames():
		force_movement(0)
		character.set_vertical_speed(0)
		
	if invicible_frames():
		character.add_invulnerability("RideArmor")
	else:
		character.remove_invulnerability("RideArmor")

func change_animation_if_falling(_s) -> void :
	pass

func _Interrupt() -> void :
	._Interrupt()
	character.remove_invulnerability("RideArmor")
	$"../animatedSprite/Ridearmor".frame = 16
