extends Fall

onready var opticshield: = $"../Shot/OpticShield"
export  var hitbox: Resource = preload("res://X_mod/UltimateX/Player/NovaStrike/NovaStrike_Hitbox.tscn")

onready var hadoken_projectiles: PackedScene = preload("res://X_mod/InfiniteX/Player/Projectiles/Hadoken.tscn")
var creator: Node2D

var hadoken_damage = 512

var ending_saber_state: bool = true
onready var arm_cannon = character.get_node("Shot")

onready var animatedSprite = character.get_node("animatedSprite")
onready var whirl_sound: AudioStreamPlayer = $whirl
onready var fire_sound: AudioStreamPlayer = $fire

var jumped: bool = false

func _ready():
	animatedSprite.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished() -> void :
	ending_saber_state = true

func end_state():
	return ending_saber_state

func invicible_frames():
	animatedSprite.material.set_shader_param("Alpha", 1)
	return animatedSprite.frame >= 0 and animatedSprite.frame <= 12

func shot_frame():
	if not jumped:
		if animatedSprite.frame >= 5:
			jumped = true
			whirl_sound.play()
			fire_sound.play()
			create_hadoken(global_position, hadoken_damage, 420)

func create_hadoken(ground_position,  damage_value, speed) -> void :
	var facing_direction = get_facing_direction()
	var instance = hadoken_projectiles.instance()
	ground_position.y += -4
	instance.damage =  damage_value
	instance.damage_to_bosses =  damage_value
	instance.damage_to_weakness =  damage_value
	instance.scale.x = facing_direction
	instance.scale.y = facing_direction
	instance.set_horizontal_speed(speed * facing_direction)
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func _StartCondition() -> bool:
	if not opticshield.has_max_ammo():
		return false
	if not arm_cannon.hadoken:
		return false
	if character.get_action_pressed("select_special"):
		return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	if not animatedSprite.animation == "hadoken" and not animatedSprite.animation == "hadoken_air":
		return true
	if end_state():
		return true
	return false

func _Setup() -> void :
	opticshield.reduce_all_ammo()
	jumped = false
	ending_saber_state = false
	if character.is_on_floor():
		animatedSprite.animation = "hadoken"
	if not character.is_on_floor():
		animatedSprite.animation = "hadoken_air"

func _Update(_delta: float) -> void :
	shot_frame()
	set_horizontal_speed(0)
	set_vertical_speed(0)
	if invicible_frames():
		character.add_invulnerability("Hadoken")
	else:
		character.remove_invulnerability("Hadoken")

func change_animation_if_falling(_s) -> void :
	if not character.is_on_floor():
		animatedSprite.animation = "fall"
	else:
		animatedSprite.animation = "recover"

func _Interrupt():
	character.remove_invulnerability("Hadoken")
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
