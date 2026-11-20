extends Fall

onready var crystalbouncer: = $"../Shot/CrystalBouncer"
export  var hitbox: Resource = preload("res://X_mod/UltimateX/Player/NovaStrike/NovaStrike_Hitbox.tscn")

onready var giga_crash_projectiles: PackedScene = preload("res://X_mod/InfiniteX/Player/Projectiles/Giga_Crash.tscn")
var creator: Node2D

var giga_crash_damage = 128

var ending_saber_state: bool = true
onready var arm_cannon = character.get_node("Shot")

onready var animatedSprite = character.get_node("animatedSprite")
onready var whirl_sound: AudioStreamPlayer = $whirl
onready var fire_sound: AudioStreamPlayer = $fire

var jumped: bool = false
var fire: bool = false

func _ready():
	animatedSprite.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished() -> void :
	ending_saber_state = true

func end_state():
	return ending_saber_state

func invicible_frames():
	animatedSprite.material.set_shader_param("Alpha", 1)
	return animatedSprite.frame >= 0 and animatedSprite.frame <= 27

func shot_frame():
	if not jumped:
		if animatedSprite.frame >= 0:
			jumped = true
			whirl_sound.play()
			create_giga_crash(global_position, giga_crash_damage, 20)
	if not fire:
		if animatedSprite.frame >= 16:
			fire = true
			fire_sound.play()

func create_giga_crash(ground_position,  damage_value, speed) -> void :
	var facing_direction = get_facing_direction()
	var instance = giga_crash_projectiles.instance()
	ground_position.y += -4
	instance.damage =  damage_value * 2
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
	if not crystalbouncer.has_max_ammo():
		return false
	if not arm_cannon.gigacrash:
		return false
	if character.get_action_pressed("select_special"):
		return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	if not animatedSprite.animation == "counter":
		return true
	if end_state():
		return true
	return false

func _Setup() -> void :
	crystalbouncer.reduce_all_ammo()
	character.can_eject = false
	jumped = false
	fire = false
	ending_saber_state = false
	if character.is_on_floor():
		animatedSprite.animation = "counter"
	if not character.is_on_floor():
		animatedSprite.animation = "counter"

func _Update(_delta: float) -> void :
	shot_frame()
	if animatedSprite.frame < 9:
		character.set_vertical_speed( - 20)
		force_movement(20)
	if animatedSprite.frame >= 9:
		set_horizontal_speed(0)
		set_vertical_speed(0)
	
	if invicible_frames():
		character.add_invulnerability("GigaCrash")
	else:
		character.remove_invulnerability("GigaCrash")

func change_animation_if_falling(_s) -> void :
	if not character.is_on_floor():
		animatedSprite.animation = "fall"
	else:
		animatedSprite.animation = "recover"

func _Interrupt():
	character.can_eject = true
	character.remove_invulnerability("GigaCrash")
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
