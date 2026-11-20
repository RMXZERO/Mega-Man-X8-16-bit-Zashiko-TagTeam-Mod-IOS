extends Movement

onready var animatedSprite = character.get_node("animatedSprite")
onready var laser: PackedScene = preload("res://src/Actors/Player/BossWeapons/OpticShield/OpticShieldCharged.tscn")
onready var ground_check: RayCast2D = $ground_check
onready var sfx: Node = $sfx
var shot_time = 0
var last_position: Vector2

var creator: Node2D
var laser_casted: bool = false



func end_ability_state() -> bool:
	if animatedSprite.animation == "tenshouha":
		return animatedSprite.frame >= 20
	return false

func cast_laser() -> void :
	if not laser_casted:
		if animatedSprite.animation == "tenshouha":
			if animatedSprite.frame >= 6:
				fire_laser()
				laser_casted = true

func _StartCondition() -> bool:
	if not character.Tenshouha:
		return false
	if not character.get_action_pressed("down_emulated"):
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
		if not _animation == "tenshouha":
			return true
		if end_ability_state():
			return true
	else:
		return true
	return false

func _Setup() -> void :
	shot_time = 0
	update_bonus_horizontal_only_conveyor()
	changed_animation = false
	laser_casted = false
	
	max_beam_offset = 32
	beam_1_offset = 0
	beam_2_offset = 1.57
	beam_3_offset = 3.14

func _Update(_delta: float) -> void :
	cast_laser()
	force_movement(0)
	
	process_gravity(_delta)
	update_bonus_horizontal_only_conveyor()
	
	crash_beam_rotation(_delta)

var max_beam_offset: float = 32
var beam_1_offset: float = 0
var beam_2_offset: float = 1.57
var beam_3_offset: float = 3.14

onready var beam_1 = get_node("crash_beam")
onready var beam_2 = get_node("crash_beam2")
onready var beam_3 = get_node("crash_beam3")

func crash_beam_rotation(_delta: float) -> void :
	if max_beam_offset > 0:
		max_beam_offset -=_delta * 100
		beam_1_offset -=_delta * 15 * get_facing_direction()
		beam_2_offset -=_delta * 15 * get_facing_direction()
		beam_3_offset -=_delta * 15 * get_facing_direction()
		beam_1.visible = true
		beam_2.visible = true
		beam_3.visible = true
	else:
		if laser_casted:
			beam_1.visible = false
			beam_2.visible = false
			beam_3.visible = false
	beam_1.position.x = 0 + max_beam_offset * sin(beam_1_offset)
	beam_2.position.x = 0 + max_beam_offset * sin(beam_2_offset)
	beam_3.position.x = 0 + max_beam_offset * sin(beam_3_offset)

func change_animation_if_falling(_s) -> void :
	pass

func _Interrupt() -> void :
	._Interrupt()
	beam_1.visible = false
	beam_2.visible = false
	beam_3.visible = false

func fire_laser() -> void :
	last_position = character.global_position
	var ground_position = Vector2(global_position.x, global_position.y + 256)
	if ground_check.is_colliding():
		ground_position = ground_check.get_collision_point()
		create_laser(ground_position)

func create_laser(ground_position) -> void :
	var instance = laser.instance()
	ground_position.y += 7
	instance.modulate = Color(1, 1, 1, 0.65)
	instance.z_index = character.z_index + 10
	instance.mid_animation_time = 0.12
	instance.end_animation_time = 1.45
	instance.deflectable = true
	instance.damage = 3
	instance.damage_to_bosses = 1.5
	instance.damage_to_weakness = 25
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())
	Event.emit_signal("screenshake", 0.5)

