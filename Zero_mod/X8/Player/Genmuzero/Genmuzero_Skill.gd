extends Movement
class_name Genmuzero

export  var hitbox: Resource = preload("res://Zero_mod/X8/Player/Genmuzero/Genmuzero_Hitbox.tscn")
onready var genmuzerowave: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/Genmuzero.tscn")
onready var genmuzerowavecustom: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/Genmuzerocustom.tscn")
export  var upgraded: bool = false

onready var awakenaura: AnimatedSprite = $"../animatedSprite/awakenaura"
onready var genmu_effect: AnimatedSprite = $"../animatedSprite/awakenaura/genmu_effect"
onready var damage: = $"../Damage"

onready var animatedSprite: = character.get_node("animatedSprite")
onready var genmu_ready: = $genmu_ready
onready var genmu_wave: = $genmu_wave
onready var check_mate: = $check_mate
onready var use_genmu: Node2D = $"../Special/Genmuzero"

var creator: Node2D

var current_hitbox: Object = null
var hitbox_upleft: Vector2 = Vector2(0, 0)
var hitbox_downright: Vector2 = Vector2(0, 0)
var hitbox_damage = 0
var hitbox_damage_boss = 0
var hitbox_damage_weakness = 0
var hitbox_break_guard_value: float = 0.25
var hitbox_break_guards: bool = true
var hitbox_rehit_time: float = 0.4

var hitbox_upgraded: bool = true
var hitbox_extra_damage = 1
var hitbox_extra_damage_boss = 1
var hitbox_extra_damage_weakness = 1
var hitbox_extra_break_guard_value = 1
var hitbox_extra_scale = 1
var genmuzero_damage = 80
var genmuzero_extra_damage = 1

var genmu_ready_played: bool = false
var genmu_wave_played: bool = false
var checkmate: bool = false
var not_hide: bool = false

func _ready() -> void :
	Event.listen("boss_health_appear",self,"boss_fight_to_long_time")

func boss_fight_to_long_time(_boss):
	Tools.timer(120.0, "long_time", self)
	Tools.timer(100.0, "check_mate_sound", self)

func check_mate_sound() -> void :
	if checkmate and not not_hide:
		check_mate.play()

func long_time() -> void :
	if checkmate:
		genmu_effect.show()
		not_hide = true
		genmuzero_extra_damage = 1024
		damage.active = false

func reset_hitbox() -> void :
	hitbox_upleft = Vector2(0, 0)
	hitbox_downright = Vector2(0, 0)
	hitbox_damage = 0
	hitbox_damage_boss = 0
	hitbox_damage_weakness = 0
	hitbox_break_guard_value = 0.25
	hitbox_break_guards = true
	hitbox_rehit_time = 0.4

func set_hitbox_corners(upleft: Vector2, downright: Vector2) -> RectangleShape2D:
	var shape = RectangleShape2D.new()
	var size = downright - upleft
	shape.extents = size / 2
	return shape

func spawn_hitbox(_hitbox_upleft: Vector2, _hitbox_downright: Vector2) -> void :
	current_hitbox = hitbox.instance()
	current_hitbox.name = "Player_Desperation"
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

func hitbox_and_position() -> void :
	hitbox_damage = 64
	hitbox_damage_boss = 64
	hitbox_damage_weakness = 64
	hitbox_break_guards = true
	hitbox_rehit_time = 1
	if animatedSprite.frame >= 8 and animatedSprite.frame < 13:
		hitbox_upleft = Vector2( - 25, - 34)
		hitbox_downright = Vector2(18, - 15)
		spawn_hitbox(hitbox_upleft, hitbox_downright)
	if animatedSprite.frame >= 9 and animatedSprite.frame < 13:
		hitbox_upleft = Vector2( - 5, - 39)
		hitbox_downright = Vector2(68, 21)
		spawn_hitbox(hitbox_upleft, hitbox_downright)
	reset_hitbox()

func play_sfx() -> void :
	var ground_position = Vector2(global_position.x, global_position.y)
	if not genmu_ready_played:
		genmu_ready.play()
		genmu_ready_played = true
	if animatedSprite.frame >= 10:
		if not genmu_wave_played:
			use_genmu.reduce_ammo(60)
			genmu_wave.play()
			genmu_wave_played = true
			if upgraded:
				if character.is_on_floor():
					create_genmuzerocustom(ground_position + Vector2( 0, - 72 ), genmuzero_damage * genmuzero_extra_damage)
				else:
					create_genmuzerocustom(ground_position + Vector2( 0, 0 ), genmuzero_damage * genmuzero_extra_damage)
			else:
				if character.is_on_floor():
					create_genmuzero(ground_position + Vector2( 0, - 84 ), genmuzero_damage * genmuzero_extra_damage)
				else:
					create_genmuzero(ground_position + Vector2( 0, 0 ), genmuzero_damage * genmuzero_extra_damage)

func create_genmuzero(ground_position, damage_value) -> void :
	var instance = genmuzerowave.instance()
	ground_position.y += 0
	instance.damage = damage_value
	instance.damage_to_bosses = damage_value
	instance.damage_to_weakness = damage_value
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func create_genmuzerocustom(ground_position, damage_value) -> void :
	var instance = genmuzerowavecustom.instance()
	ground_position.y += 0
	if CharacterManager.awakened_zero_armor and CharacterManager.awakened_zero_full_power_max:
		instance.name = "Player_Desperation"
	instance.damage = damage_value
	instance.damage_to_bosses = damage_value
	instance.damage_to_weakness = damage_value
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func end_state():
	if animatedSprite.animation == "genmuzero":
		return animatedSprite.frame >= 19
	elif animatedSprite.animation == "genmuzeroair":
		return animatedSprite.frame >= 19

func invicible_frames() -> bool:
	animatedSprite.material.set_shader_param("Alpha", 1)
	return animatedSprite.frame >= 0 and animatedSprite.frame < 23

func movement_frames() -> bool:
	return animatedSprite.frame >= 9 and animatedSprite.frame < 23

func _StartCondition() -> bool:
	if not use_genmu.has_ammo_expent(60):
		return false
	if character.get_action_pressed("move_down") and character.is_on_floor() and CharacterManager.extra_saber_05:
		return false
	if character.get_action_pressed("move_up") and character.is_on_floor() and CharacterManager.player_desperation:
		return false
	if character.get_action_pressed("alt_fire"):
		return false
	if animatedSprite.animation == "charge_sentsuizan":
		return false
	if character.get_action_pressed("select_special"):
		return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	if end_state():
		return true
	if not animatedSprite.animation == "genmuzero" and not animatedSprite.animation == "genmuzeroair":
		return true
	return false

func _Setup() -> void :
	genmu_ready_played = false
	genmu_wave_played = false
	if character.is_on_floor():
		animatedSprite.animation = "genmuzero"
	else:
		animatedSprite.animation = "genmuzeroair"

func _Update(_delta: float) -> void :
	update_bonus_horizontal_only_conveyor()
	if animatedSprite.animation == "genmuzero" or animatedSprite.animation == "genmuzeroair":
		set_horizontal_speed(0)
		set_vertical_speed(0)
		hitbox_and_position()
		play_sfx()
		
	if invicible_frames():
		character.add_invulnerability("Genmuzero")
	else:
		character.remove_invulnerability("Genmuzero")
		
	if CharacterManager.betazero_activated and CharacterManager.extra_saber_color:
		return
	if animatedSprite.animation == "genmuzero" or animatedSprite.animation == "genmuzeroair":
		if animatedSprite.frame <= 19:
			awakenaura.show()
			awakenaura.speed_scale = 10/3
			genmu_effect.show()

func change_animation_if_falling(_s) -> void :
	pass

func _Interrupt() -> void :
	._Interrupt()
	character.can_eject = true
	character.remove_invulnerability("Genmuzero")
	if is_instance_valid(current_hitbox):
		current_hitbox.queue_free()
	awakenaura.speed_scale = 1
	if not not_hide:
		genmu_effect.hide()
	if not CharacterManager.awakened_zero_armor:
		awakenaura.hide()
	else:
		awakenaura.show()
	if CharacterManager.betazero_activated and CharacterManager.extra_saber_color:
		awakenaura.hide()
