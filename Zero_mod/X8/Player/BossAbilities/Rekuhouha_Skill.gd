extends Movement
class_name SaberRekuhouhaX8

onready var animatedSprite = character.get_node("animatedSprite")
onready var rekohouhaground: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/RekohouhaGround.tscn")
onready var rekohouha: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/Rekohouha.tscn")
onready var use_genmu: Node2D = $"../Special/Genmuzero"
onready var effect_animation = preload("res://Zero_mod/X8/Sprites/Saber/BossAbilities/ability_effects.tres")
onready var ground_check: RayCast2D = $ground_check
onready var laser_cast_frame: int = 5
onready var sfx: Node = $sfx
var shot_time = 0
var last_position: Vector2
var messenkou_damage = 5

onready var rekohouhashot_sound: AudioStreamPlayer = $RekohouhaShot
onready var rekohouhaground_sound: AudioStreamPlayer = $RekohouhaGround
var ending_saber_state: bool = false
var creator: Node2D
var laser_casted: bool = false


func _ready() -> void :
	animatedSprite.connect("animation_finished", self, "_on_animation_finished")
	
func _on_animation_finished() -> void :
	ending_saber_state = true

func end_ability_state() -> bool:
	return ending_saber_state

func cast_laser() -> void :
	if not laser_casted:
		if animatedSprite.animation == "tenshouha" or animatedSprite.animation == "rekuhouha":
			if animatedSprite.frame >= laser_cast_frame:
				fire_laser()
				laser_casted = true

func _StartCondition() -> bool:
	if not CharacterManager.extra_saber_combo:
		return false
	if not CharacterManager.extra_saber_05:
		return false
	if not use_genmu.has_ammo_expent(CharacterManager.buster_base_energy * 0.5) and not CharacterManager.awakened_zero_armor:
		return false
	if not character.get_action_pressed("move_down"):
		return false
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		return false
	if not executing:
		if character.is_on_floor():
			return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		if not _animation == "tenshouha" and not _animation == "rekuhouha":
			return true
		if end_ability_state():
			return true
	else:
		return true
	return false

var effect: AnimatedSprite
var effect_transparency: float = 0.75
func effect_emit(_animation, flip_h:bool) -> void :
	effect = AnimatedSprite.new()
	add_child(effect)
	effect.frames = effect_animation
	effect.animation = _animation
	effect.frame = animatedSprite.frame
	effect.playing = true
	effect.global_position = global_position
	effect.modulate = Color(1, 1, 1, effect_transparency)
	effect.scale = animatedSprite.scale
	effect.z_index = animatedSprite.z_index + 1
	effect.centered = animatedSprite.centered
	effect.offset.y = animatedSprite.offset.y - 3
	effect.rotation_degrees = animatedSprite.rotation_degrees
	if flip_h:
		effect.flip_h = true
		effect.flip_v = animatedSprite.flip_v
	else:
		effect.flip_h = animatedSprite.flip_h
		effect.flip_v = animatedSprite.flip_v

func _Setup() -> void :
	if character.saber_node.current_weapon.name == "Saber":
		if CharacterManager.betazero_activated:
			effect_emit("tenshouha_effect",false)
		else:
			effect_emit("tenshouha_effect",true)

	elif character.saber_node.current_weapon.name == "Z-Breaker":
		effect_emit("tenshouha_effect",false)

	elif character.saber_node.current_weapon.name == "B-Fan":
		effect_emit("tenshouha_effect",true)

	elif character.saber_node.current_weapon.name == "D-Glaive":
		effect_emit("tenshouha_effect",true)

	elif character.saber_node.current_weapon.name == "K-Knuckle":
		effect_emit("tenshouha_effect_knuckle",false)

	elif character.saber_node.current_weapon.name == "T-Breaker":
		effect_emit("tenshouha_effect",true)

	elif character.saber_node.current_weapon.name == "V-Hanger":
		effect_emit("tenshouha_effect",false)
		
	elif character.saber_node.current_weapon.name == "Rogue-Blade":
		effect_emit("tenshouha_effect",true)

	elif character.saber_node.current_weapon.name == "Sigma-Blade":
		effect_emit("tenshouha_effect",true)

	else:
		if CharacterManager.betazero_activated:
			effect_emit("tenshouha_effect",false)
		else:
			effect_emit("tenshouha_effect",true)
	
	shot_time = 0
	update_bonus_horizontal_only_conveyor()
	changed_animation = false
	laser_casted = false
	ending_saber_state = false
	set_saber_animations()

func set_saber_animations() -> void :
	animatedSprite.animation = "tenshouha"

func _Update(_delta: float) -> void :
	cast_laser()
	force_movement(0)
	
	process_gravity(_delta)
	update_bonus_horizontal_only_conveyor()

func change_animation_if_falling(_s) -> void :
	pass

func _Interrupt() -> void :
	._Interrupt()
	if is_instance_valid(effect):
		effect.queue_free()
		effect = null

func fire_laser() -> void :
	last_position = character.global_position
	rekohouhaground_sound.play()
	summon_rekohouha()
	Tools.timer(0.1, "summon_rekohouha", self)
	Tools.timer(0.2, "summon_rekohouha", self)
	Tools.timer(0.3, "summon_rekohouha", self)
	Tools.timer(0.4, "summon_rekohouha", self)
	Tools.timer(0.5, "summon_rekohouha", self)
	if not CharacterManager.awakened_zero_armor:
		use_genmu.reduce_ammo(CharacterManager.buster_base_energy * 0.5)
	if character.saber_node.current_weapon.name == "K-Knuckle":
		animatedSprite.frame = 7

func summon_rekohouha() -> void :
	if not CharacterManager.player_character == "Zero":
		return
	var ground_position = Vector2(last_position.x, global_position.y + 256)
	if ground_check.is_colliding():
		ground_position = ground_check.get_collision_point()
		rekohouhashot_sound.play()
		create_rekohouhaground(ground_position + Vector2(30 + shot_time * 60, 0))
		create_rekohouhaground(ground_position + Vector2(-30 + shot_time * - 60, 0))
		create_rekohouha(ground_position + Vector2(30 + shot_time * 60, 0))
		create_rekohouha(ground_position + Vector2(-30 + shot_time * - 60, 0))
	shot_time += 1

func create_rekohouha(ground_position) -> void :
	var instance = rekohouha.instance()
	ground_position.y += 10
	instance.damage = CharacterManager.z_buster_base_damage * 2
	instance.damage_to_bosses = CharacterManager.z_buster_base_damage * 2
	instance.damage_to_weakness = CharacterManager.z_buster_base_damage * 2
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func create_rekohouhaground(ground_position) -> void :
	var instance = rekohouhaground.instance()
	ground_position.y += -25
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())
	Event.emit_signal("screenshake", 0.2)



