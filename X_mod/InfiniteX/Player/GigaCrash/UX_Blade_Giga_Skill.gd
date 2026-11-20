extends Fall

onready var thunderdancer: = $"../Shot/ThunderDancer"
export  var hitbox: Resource = preload("res://X_mod/UltimateX/Player/NovaStrike/NovaStrike_Hitbox.tscn")

onready var blade_projectiles: PackedScene = preload("res://X_mod/InfiniteX/Player/Projectiles/Blade_Giga.tscn")
var creator: Node2D

var current_hitbox = null
var hitbox_upleft = Vector2(0, 0)
var hitbox_downright = Vector2(0, 0)
var hitbox_damage = 0
var hitbox_damage_boss = 0
var hitbox_damage_weakness = 0
var hitbox_break_guard_value = 0.25
var hitbox_break_guards: bool = true
var hitbox_rehit_time = 0.075

var hitbox_upgraded: bool = true
var hitbox_extra_damage = 1
var hitbox_extra_damage_boss = 1
var hitbox_extra_damage_weakness = 1
var hitbox_extra_break_guard_value = 1

var blade_giga_damage = 64

var deflectable: bool = true
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

func reset_hitbox():
	hitbox_upleft = Vector2(0, 0)
	hitbox_downright = Vector2(0, 0)
	hitbox_damage = 0
	hitbox_damage_boss = 0
	hitbox_damage_weakness = 0
	hitbox_break_guard_value = 0.25
	hitbox_break_guards = true
	hitbox_rehit_time = 0.4
	
func set_hitbox_corners(upleft: Vector2, downright: Vector2):
	var shape = RectangleShape2D.new()
	var size = downright - upleft
	shape.extents = size / 2
	return shape
	
func spawn_hitbox(_hitbox_upleft: Vector2, _hitbox_downright: Vector2):
	current_hitbox = hitbox.instance()
	current_hitbox.name = "NovaStrikeCharged"
	var collision_shape_node = current_hitbox.get_node("collisionShape2D")
	if collision_shape_node == null:
		return
	else:
		current_hitbox.collision_shape = collision_shape_node
	
	var hitbox_shape = set_hitbox_corners(_hitbox_upleft, _hitbox_downright)
	var hitbox_position = Vector2(0, 0)
	
	var facing_direction = get_facing_direction()
	if facing_direction == - 1:
		var temp_upleft = Vector2( - _hitbox_downright.x, _hitbox_upleft.y)
		var temp_downright = Vector2( - _hitbox_upleft.x, _hitbox_downright.y)
		hitbox_shape = set_hitbox_corners(temp_upleft, temp_downright)
		hitbox_position = (temp_upleft + temp_downright) / 2
	else:
		hitbox_shape = set_hitbox_corners(_hitbox_upleft, _hitbox_downright)
		hitbox_position = (_hitbox_upleft + _hitbox_downright) / 2
	
	current_hitbox.collision_shape.shape = hitbox_shape
	current_hitbox.position = hitbox_position
	
	add_child(current_hitbox)
		
	current_hitbox.damage = hitbox_damage * hitbox_extra_damage
	current_hitbox.damage_to_bosses = hitbox_damage_boss * hitbox_extra_damage_boss
	current_hitbox.damage_to_weakness = hitbox_damage_weakness * hitbox_extra_damage_weakness
	current_hitbox.break_guards = hitbox_break_guards
	current_hitbox.upgraded = hitbox_upgraded
	current_hitbox.rehit = hitbox_rehit_time
	

func hitbox_and_position():
	hitbox_damage = blade_giga_damage/1
	hitbox_damage_boss = blade_giga_damage/2
	hitbox_damage_weakness = blade_giga_damage/2
	hitbox_break_guards = true
	hitbox_rehit_time = 0.1
	if animatedSprite.frame >= 5 and animatedSprite.frame < 8:
		hitbox_upleft = Vector2( -22, - 40)
		hitbox_downright = Vector2(50, 10)
		spawn_hitbox(hitbox_upleft, hitbox_downright)
	reset_hitbox()

func end_state():
	return ending_saber_state

func invicible_frames():
	animatedSprite.material.set_shader_param("Alpha", 1)
	return animatedSprite.frame >= 0 and animatedSprite.frame <= 16

func shot_frame():
	if not jumped:
		if animatedSprite.frame >= 6:
			jumped = true
			whirl_sound.play()
			fire_sound.play()
			summon_blade_wave_big()
			Tools.timer(0.05, "summon_blade_wave_mid", self)
			Tools.timer(0.1, "summon_blade_wave_mini", self)

func summon_blade_wave_big() -> void :
	create_blade_wave(global_position, blade_giga_damage, 600, 3)

func summon_blade_wave_mid() -> void :
	create_blade_wave(global_position, blade_giga_damage, 600, 2)

func summon_blade_wave_mini() -> void :
	create_blade_wave(global_position, blade_giga_damage, 600, 1)

func create_blade_wave(ground_position,  damage_value, speed, size) -> void :
	var facing_direction = get_facing_direction()
	var instance = blade_projectiles.instance()
	ground_position.y += -4
	instance.damage =  damage_value * 2
	instance.damage_to_bosses =  damage_value
	instance.damage_to_weakness =  damage_value * 2
	if size == 3:
		instance.big_wave =  true
	if size == 2:
		instance.mid_wave =  true
	if size == 1:
		instance.mini_wave =  true
	instance.scale.x = facing_direction
	instance.scale.y = facing_direction
	instance.set_horizontal_speed(speed * facing_direction)
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func _StartCondition() -> bool:
	if not thunderdancer.has_max_ammo():
		return false
	if not arm_cannon.bladegiga:
		return false
	if character.get_action_pressed("select_special"):
		return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	if not animatedSprite.animation == "saber" and not animatedSprite.animation == "saber_air":
		return true
	if end_state():
		return true
	return false

func _Setup() -> void :
	thunderdancer.reduce_all_ammo()
	jumped = false
	ending_saber_state = false
	if character.is_on_floor():
		animatedSprite.animation = "saber"
	if not character.is_on_floor():
		animatedSprite.animation = "saber_air"

func _Update(_delta: float) -> void :
	shot_frame()
	hitbox_and_position()
	set_horizontal_speed(0)
	set_vertical_speed(0)
	if invicible_frames():
		character.add_invulnerability("BladeGiga")
	else:
		character.remove_invulnerability("BladeGiga")

func change_animation_if_falling(_s) -> void :
	if not character.is_on_floor():
		animatedSprite.animation = "fall"
	else:
		animatedSprite.animation = "recover"

func _Interrupt():
	character.remove_invulnerability("BladeGiga")
	if is_instance_valid(current_hitbox):
		current_hitbox.queue_free()
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
