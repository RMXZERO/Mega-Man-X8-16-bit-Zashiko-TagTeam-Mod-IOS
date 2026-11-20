extends Movement
class_name SaberTenshouhaX8

onready var animatedSprite = character.get_node("animatedSprite")
onready var laser = preload("res://src/Actors/Player/BossWeapons/OpticShield/OpticShieldCharged.tscn")
onready var arrow: PackedScene = preload("res://Zero_mod/X8/Sprites/vhanger/object/HangerArrow.tscn")
onready var rogueslash: PackedScene = preload("res://Zero_mod/X8/Sprites/rogueblade/object/rogueslash.tscn")
onready var rekohouha: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/Rekohouha.tscn")
onready var crashbeam: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/RekohouhaX6.tscn")
onready var effect_animation = preload("res://Zero_mod/X8/Sprites/Saber/BossAbilities/ability_effects.tres")
onready var use_genmu: Node2D = $"../Special/Genmuzero"
onready var ground_check: RayCast2D = $ground_check
onready var laser_cast_frame: int = 5
onready var sfx: Node = $sfx
var shot_time = 0
var last_position: Vector2
var first_time_casted: bool = false

onready var hangerarrow_sound: AudioStreamPlayer = $HangerArrow
onready var roguewave_sound: AudioStreamPlayer = $RogueWave
onready var rekohouha_sound: AudioStreamPlayer = $RekohouhaShot
onready var crashbeam_sound: AudioStreamPlayer = $CrashBeam
onready var ground_sound: AudioStreamPlayer = $ground
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
		if animatedSprite.animation == "tenshouha":
			if animatedSprite.frame >= laser_cast_frame:
				fire_laser()
				laser_casted = true
		if animatedSprite.animation == "saber_shot_normal":
			if animatedSprite.frame >= laser_cast_frame:
				fire_laser()
				laser_casted = true

func _StartCondition() -> bool:
	if not character.Tenshouha:
		return false
	if not use_genmu.has_ammo_expent(CharacterManager.buster_base_energy * 0.5) and character.saber_node.current_weapon.name == "Z-Breaker":
		if not CharacterManager.awakened_zero_armor:
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
		if not _animation == "tenshouha" and not _animation == "saber_shot_normal":
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
	effect.z_index = animatedSprite.z_index + 25
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
	shot_time = 0
	update_bonus_horizontal_only_conveyor()
	changed_animation = false
	laser_casted = false
	first_time_casted = false
	ending_saber_state = false
	set_saber_animations()

	max_beam_offset = 32
	beam_1_offset = 0
	beam_2_offset = 1.57
	beam_3_offset = 3.14

func set_saber_animations() -> void :
	animatedSprite.animation = "tenshouha"
	if character.saber_node.current_weapon.name == "V-Hanger":
		animatedSprite.animation = "saber_shot_normal"
	elif character.saber_node.current_weapon.name == "Rogue-Blade":
		animatedSprite.animation = "saber_shot_normal"
	if not character.saber_node.current_weapon.name == "K-Knuckle":
		animatedSprite.frame = 1
	if character.saber_node.current_weapon.name == "Z-Breaker":
		effect_emit("tenshouha_effect",false)

func _Update(_delta: float) -> void :
	cast_laser()
	force_movement(0)
	
	process_gravity(_delta)
	update_bonus_horizontal_only_conveyor()
	if animatedSprite.animation == "tenshouha" and not character.saber_node.current_weapon.name == "K-Knuckle" and animatedSprite.frame >= 3 and not first_time_casted:
		first_time_casted = true
		if not character.saber_node.current_weapon.name == "Z-Breaker":
			animatedSprite.frame = 2
	
	if character.saber_node.current_weapon.name == "Z-Breaker":
		if is_instance_valid(effect):
			effect.frame = animatedSprite.frame
			effect.global_position = global_position
			effect.rotation_degrees = animatedSprite.rotation_degrees
			
	crash_beam_rotation(_delta)

func change_animation_if_falling(_s) -> void :
	pass

var max_beam_offset: float = 32
var beam_1_offset: float = 0
var beam_2_offset: float = 1.57
var beam_3_offset: float = 3.14

onready var beam_1 = get_node("crash_beam")
onready var beam_2 = get_node("crash_beam2")
onready var beam_3 = get_node("crash_beam3")

func crash_beam_rotation(_delta: float) -> void :
	if character.saber_node.current_weapon.name == "V-Hanger":
		return
	if character.saber_node.current_weapon.name == "Rogue-Blade":
		return
	if character.saber_node.current_weapon.name == "Z-Breaker":
		return
	if max_beam_offset > 0:
		if character.saber_node.current_weapon.name == "K-Knuckle":
			max_beam_offset -=_delta * 150
		else:
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

func _Interrupt() -> void :
	._Interrupt()
	character.remove_invulnerability("Tenshouha")
	if is_instance_valid(effect):
		effect.queue_free()
		effect = null
	beam_1.visible = false
	beam_2.visible = false
	beam_3.visible = false


func fire_laser() -> void :
	character.add_invulnerability("Tenshouha")
	animatedSprite.material.set_shader_param("Alpha", 1)
	last_position = character.global_position
	var ground_position = Vector2(global_position.x, global_position.y + 256)
	if character.saber_node.current_weapon.name == "Saber" or \
	character.saber_node.current_weapon.name == "B-Fan" or \
	character.saber_node.current_weapon.name == "D-Glaive" or \
	character.saber_node.current_weapon.name == "T-Breaker" or \
	character.saber_node.current_weapon.name == "K-Knuckle":
		if ground_check.is_colliding():
			ground_position = ground_check.get_collision_point()
			create_laser(ground_position)
			if CharacterManager.awakened_zero_armor:
				create_laser(ground_position + Vector2( + 40, 0))
				create_laser(ground_position + Vector2( - 40, 0))
	if character.saber_node.current_weapon.name == "V-Hanger":
			hangerarrow_sound.play()
			if CharacterManager.awakened_zero_armor:
				create_arrow(global_position, 10)
			elif CharacterManager.black_zero_armor:
				create_arrow(global_position, 6)
			else:
				create_arrow(global_position, 5)
	if character.saber_node.current_weapon.name == "Rogue-Blade":
			roguewave_sound.play()
			if CharacterManager.awakened_zero_armor:
				create_rogueslash(global_position, 10)
			elif CharacterManager.black_zero_armor:
				create_rogueslash(global_position, 6)
			else:
				create_rogueslash(global_position, 5)
	if character.saber_node.current_weapon.name == "Sigma-Blade":
		if ground_check.is_colliding():
			ground_position = ground_check.get_collision_point()
			if CharacterManager.awakened_zero_armor:
				create_lasershort(ground_position)
				shot_time += 1
				Tools.timer(0.1, "summon_lasershort", self)
				Tools.timer(0.2, "summon_lasershort", self)
				Tools.timer(0.3, "summon_lasershort", self)
				Tools.timer(0.4, "summon_lasershort", self)
				Tools.timer(0.5, "summon_lasershort", self)
				Tools.timer(0.6, "summon_lasershort", self)
			else:
				create_laser(ground_position)
				create_laser(ground_position + Vector2( + 40, 0))
				create_laser(ground_position + Vector2( - 40, 0))

	if character.saber_node.current_weapon.name == "Z-Breaker":
		if character.get_action_pressed("select_special") and use_genmu.has_ammo_expent(CharacterManager.buster_base_energy * 1.5):
			if ground_check.is_colliding():
				ground_position = ground_check.get_collision_point()
				crashbeam_sound.play()
				ground_sound.play()
				create_crashbeam(last_position, 1)
				shot_time += 1
				Tools.timer(0.2, "summon_rekohouha", self)
				Tools.timer(0.4, "summon_rekohouha", self)
				Tools.timer(0.6, "summon_rekohouha", self)
				Tools.timer(0.8, "summon_rekohouha", self)
				Tools.timer(1.0, "summon_rekohouha", self)
				Tools.timer(1.2, "summon_rekohouha", self)
				if not CharacterManager.awakened_zero_armor:
					use_genmu.reduce_ammo(CharacterManager.buster_base_energy * 1.5)
		else:
			if ground_check.is_colliding():
				ground_position = ground_check.get_collision_point()
				rekohouha_sound.play()
				ground_sound.play()
				create_rekohouha(global_position, 0)
				create_rekohouha(global_position, 22.5)
				create_rekohouha(global_position, 45)
				create_rekohouha(global_position, 67.5)
				create_rekohouha(global_position, 90)
				create_rekohouha(global_position, -22.5)
				create_rekohouha(global_position, -45)
				create_rekohouha(global_position, -67.5)
				create_rekohouha(global_position, -90)
				if not CharacterManager.awakened_zero_armor:
					use_genmu.reduce_ammo(CharacterManager.buster_base_energy * 0.25)

func summon_rekohouha() -> void :
	if not CharacterManager.player_character == "Zero":
		return
	if shot_time == 1 or shot_time == 3 or shot_time == 5 or shot_time == 7:
		create_crashbeam(last_position + Vector2( shot_time * 30, 0), -1)
		create_crashbeam(last_position + Vector2( shot_time * - 30, 0), -1)
	else:
		create_crashbeam(last_position + Vector2( shot_time * 30, 0), 1)
		create_crashbeam(last_position + Vector2( shot_time * - 30, 0), 1)
	crashbeam_sound.play()
	animatedSprite.frame = 11
	shot_time += 1

func summon_lasershort() -> void :
	if not CharacterManager.player_character == "Zero":
		return
	var ground_position = Vector2(last_position.x, last_position.y + 256)
	if ground_check.is_colliding():
		ground_position = ground_check.get_collision_point()
		create_lasershort(ground_position + Vector2( shot_time * 40, 0))
		create_lasershort(ground_position + Vector2( shot_time * - 40, 0))
	shot_time += 1

func invicible_frames() -> bool:
	return animatedSprite.frame >= 6 and animatedSprite.frame < 12

func deflect_projectile(body):
	if body.is_in_group("Enemy Projectile"):
		if body.has_method("_OnHit"):
			body._OnHit(self)
			return
		body.destroy()

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

func create_lasershort(ground_position) -> void :
	var instance = laser.instance()
	ground_position.y += 7
	instance.modulate = Color(1, 1, 1, 0.65)
	instance.z_index = character.z_index + 10
	instance.mid_animation_time = 0.12
	instance.end_animation_time = 0.36
	instance.deflectable = true
	instance.damage = 6
	instance.damage_to_bosses = 3
	instance.damage_to_weakness = 30
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())
	Event.emit_signal("screenshake", 0.5)

func create_arrow(global_position, damage_value) -> void :
	var instance = arrow.instance()
	instance.damage = damage_value * 2
	instance.damage_to_bosses = damage_value
	instance.damage_to_weakness = damage_value
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(global_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func create_rogueslash(global_position, damage_value) -> void :
	var instance = rogueslash.instance()
	instance.damage = damage_value
	instance.damage_to_bosses = damage_value
	instance.damage_to_weakness = damage_value
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(global_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func create_rekohouha(ground_position, degrees: float) -> void :
	var instance = rekohouha.instance()
	ground_position.y += 5
	instance.damage = CharacterManager.z_buster_base_damage * 2
	instance.damage_to_bosses = CharacterManager.z_buster_base_damage * 2
	instance.damage_to_weakness = CharacterManager.z_buster_base_damage * 2
	instance.rotate_degrees(degrees)
	instance.rekohouha = false
	if degrees == 0:
		instance.set_vertical_speed(-420)
	if degrees == 22.5:
		instance.set_vertical_speed(-366.78)
		instance.set_horizontal_speed(160.72)
	if degrees == 45:
		instance.set_vertical_speed(-296.94)
		instance.set_horizontal_speed(296.94)
	if degrees == 67.5:
		instance.set_vertical_speed(-160.72)
		instance.set_horizontal_speed(366.78)
	if degrees == 90:
		instance.set_horizontal_speed(420)
	if degrees == -22.5:
		instance.set_vertical_speed(-366.78)
		instance.set_horizontal_speed(-160.72)
	if degrees == -45:
		instance.set_vertical_speed(-296.94)
		instance.set_horizontal_speed(-296.94)
	if degrees == -67.5:
		instance.set_vertical_speed(-160.72)
		instance.set_horizontal_speed(-366.78)
	if degrees == -90:
		instance.set_horizontal_speed(-420)
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())
	Event.emit_signal("screenshake", 0.3)

func create_crashbeam(ground_position, down_value) -> void :
	var instance = crashbeam.instance()
	ground_position.y += 10
	instance.damage = CharacterManager.z_buster_base_damage * 5
	instance.damage_to_bosses = CharacterManager.z_buster_base_damage * 5
	instance.damage_to_weakness = CharacterManager.z_buster_base_damage * 5
	instance.speed = 1200 * down_value
	instance.scale.y = 1 * down_value
	instance.z_index += 25
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())
	Event.emit_signal("screenshake", 0.3)
