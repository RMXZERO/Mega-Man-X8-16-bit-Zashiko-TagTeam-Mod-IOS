extends Fall

onready var darkarrow: = $"../Shot/DarkArrow"
export  var hitbox: Resource = preload("res://X_mod/UltimateX/Player/NovaStrike/NovaStrike_Hitbox.tscn")

onready var falcon_projectiles: PackedScene = preload("res://X_mod/InfiniteX/Player/Projectiles/Falcon.tscn")
var creator: Node2D

var falcon_giga_damage = 32

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
	return animatedSprite.frame >= 0 and animatedSprite.frame <= 35

func shot_frame():
	if not jumped:
		if animatedSprite.frame >= 10:
			jumped = true
			whirl_sound.play()
			fire_sound.play()
			summon_falcon()
			Tools.timer(0.05, "summon_falcon", self)
			Tools.timer(0.1, "summon_falcon", self)
			Tools.timer(0.15, "summon_falcon", self)
			Tools.timer(0.2, "summon_falcon", self)
			Tools.timer(0.25, "summon_falcon", self)
			Tools.timer(0.3, "summon_falcon", self)
			Tools.timer(0.35, "summon_falcon", self)
			Tools.timer(0.4, "summon_falcon", self)
			Tools.timer(0.45, "summon_falcon", self)
			Tools.timer(0.5, "summon_falcon", self)
			Tools.timer(0.55, "summon_falcon", self)
			Tools.timer(0.6, "summon_falcon", self)
			Tools.timer(0.65, "summon_falcon", self)
			Tools.timer(0.7, "summon_falcon", self)
			Tools.timer(0.75, "summon_falcon", self)
			Tools.timer(0.8, "summon_falcon", self)
			Tools.timer(0.85, "summon_falcon", self)
			Tools.timer(0.9, "summon_falcon", self)
			Tools.timer(0.95, "summon_falcon", self)

func summon_falcon() -> void :
	if not CharacterManager.player_character == "X":
		return
	create_falcon_up(global_position, falcon_giga_damage, 420)
	create_falcon_down(global_position, falcon_giga_damage, -420)

func create_falcon_up(ground_position,  damage_value, speed) -> void :
	var facing_direction = get_facing_direction()
	var instance = falcon_projectiles.instance()
	ground_position.y += -220
	instance.gigaattack = true
	instance.damage =  damage_value * 2
	instance.damage_to_bosses =  damage_value
	instance.damage_to_weakness =  damage_value * 2
	instance.scale.x = 1
	instance.scale.y = 1
	instance.set_vertical_speed(speed)
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func create_falcon_down(ground_position,  damage_value, speed) -> void :
	var facing_direction = get_facing_direction()
	var instance = falcon_projectiles.instance()
	ground_position.y += 220
	instance.gigaattack = true
	instance.damage =  damage_value * 2
	instance.damage_to_bosses =  damage_value
	instance.damage_to_weakness =  damage_value
	instance.scale.x = -1
	instance.scale.y = -1
	instance.set_vertical_speed(speed)
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func _StartCondition() -> bool:
	if not darkarrow.has_max_ammo():
		return false
	if not arm_cannon.darkarrow:
		return false
	if character.get_action_pressed("select_special"):
		return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	if not animatedSprite.animation == "falcongiga":
		return true
	if end_state():
		return true
	return false

func _Setup() -> void :
	darkarrow.reduce_all_ammo()
	jumped = false
	ending_saber_state = false
	animatedSprite.animation = "falcongiga"

func _Update(_delta: float) -> void :
	shot_frame()
	set_horizontal_speed(0)
	set_vertical_speed(0)
	if invicible_frames():
		character.add_invulnerability("FalconGiga")
	else:
		character.remove_invulnerability("FalconGiga")

func change_animation_if_falling(_s) -> void :
	if not character.is_on_floor():
		animatedSprite.animation = "fall"
	else:
		animatedSprite.animation = "recover"

func _Interrupt():
	character.remove_invulnerability("FalconGiga")
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
