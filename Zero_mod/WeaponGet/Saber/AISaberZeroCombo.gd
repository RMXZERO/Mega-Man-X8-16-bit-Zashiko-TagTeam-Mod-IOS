extends FallZero

export  var saber_hitbox: Resource = preload("res://Zero_mod/Player/Hitboxes/Saber_Hitbox.tscn")

onready var saber_sound: AudioStreamPlayer = $saber
onready var saber2_sound: AudioStreamPlayer = $saber2
onready var saber3_sound: AudioStreamPlayer = $saber3

onready var zbuster_sound: AudioStreamPlayer = $zbuster
onready var swordwave_sound: AudioStreamPlayer = $swordwave
onready var shingetsurin_sound: AudioStreamPlayer = $shingetsurin
onready var swordwave: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/swordwave.tscn")
onready var zbuster: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/zbuster.tscn")
onready var shingetsurin: PackedScene = preload("res://Zero_mod/X8/Sprites/zbuster/object/shingetsurin.tscn")
var creator: Node2D
var use_shingetsurin: bool = false

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

var deflectable: bool = true
var hitbox_extra_scale = 1
var ending_saber_state: bool = true
onready var arm_cannon = character.get_node("Shot")

onready var animatedSprite = character.get_node("animatedSprite")

var input_buffer = []
var buffer_window_threshold = 3
var slashing: bool = false
var slashes = 0

func _ready():
	animatedSprite.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished() -> void :
	ending_saber_state = true

func saber_color() -> void:
	if character.weaponget:
		saber_rekkyoudan_on()
		return
	if arm_cannon.current_weapon.name == "CrystalBouncer" or CharacterManager.rekkyoudan_active:
		saber_rekkyoudan_on()
	else:
		saber_rekkyoudan_off()

func saber_rekkyoudan_on() -> void:
	character.saber_combo.deflectable = true
	character.saber_dash.deflectable = true
	character.saber_jump.deflectable = true
	character.saber_wall.deflectable = true
	
	character.skill_juuhazan.deflectable = true
	character.skill_rasetsusen.deflectable = true
	character.skill_raikousen.deflectable = true
	character.skill_youdantotsu.deflectable = true
	character.skill_hyouryuushou.deflectable = true
	character.skill_enkoujin.deflectable = true
	
	character.saber_combo.saber_hitbox = character.rekkyoudan_hitbox
	character.saber_dash.saber_hitbox = character.rekkyoudan_hitbox
	character.saber_jump.saber_hitbox = character.rekkyoudan_hitbox
	character.saber_wall.saber_hitbox = character.rekkyoudan_hitbox
	saber_hitbox = character.rekkyoudan_hitbox

func saber_rekkyoudan_off() -> void:
	character.saber_combo.deflectable = false
	character.saber_dash.deflectable = false
	character.saber_jump.deflectable = false
	character.saber_wall.deflectable = false
	
	character.skill_juuhazan.deflectable = false
	character.skill_rasetsusen.deflectable = false
	character.skill_raikousen.deflectable = false
	character.skill_youdantotsu.deflectable = false
	character.skill_hyouryuushou.deflectable = false
	character.skill_enkoujin.deflectable = false

	character.saber_combo.saber_hitbox = character.saber_hitbox
	character.saber_dash.saber_hitbox = character.saber_hitbox
	character.saber_jump.saber_hitbox = character.saber_hitbox
	character.saber_wall.saber_hitbox = character.saber_hitbox
	saber_hitbox = character.saber_hitbox

func hitbox_name():
	saber_color()
	if arm_cannon.current_weapon.name == "OpticShield":
		if hitbox_break_guards:
			current_hitbox.name = "OpticShieldCharged"
	elif arm_cannon.current_weapon.name == "SqueezeBomb":
		if hitbox_break_guards:
			current_hitbox.name = "SqueezeBombCharged"
	elif arm_cannon.current_weapon.name == "DarkArrow":
		if hitbox_break_guards:
			current_hitbox.name = "DarkArrowCharged"
	elif arm_cannon.current_weapon.name == "ThunderDancer":
		if hitbox_break_guards:
			current_hitbox.name = "ThunderDancerCharged"
	elif arm_cannon.current_weapon.name == "BlastLauncher":
		if hitbox_break_guards:
			current_hitbox.name = "BlastLaunchCharged"
	elif arm_cannon.current_weapon.name == "CrystalBouncer":
		if hitbox_break_guards:
			current_hitbox.name = "CrystalBouncerCharged"
	elif arm_cannon.current_weapon.name == "DriftDiamond":
		if hitbox_break_guards:
			current_hitbox.name = "DriftDiamondCharged"
	elif arm_cannon.current_weapon.name == "FireDash":
		if hitbox_break_guards:
			current_hitbox.name = "FireDashCharged"
	else:
		CharacterManager.set_saberX8_colors(animatedSprite)
		if hitbox_break_guards:
			current_hitbox.name = "Saber"

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
	current_hitbox = saber_hitbox.instance()
	hitbox_name()
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
	current_hitbox.saber_rehit = hitbox_rehit_time
	current_hitbox.upgraded = hitbox_upgraded
	current_hitbox.scale *= hitbox_extra_scale
	
	current_hitbox.deflectable = deflectable

func hitbox_and_position():
	if animatedSprite.animation == "saber_1":
		hitbox_damage = 2
		hitbox_damage_boss = 4
		hitbox_damage_weakness = 24
		hitbox_rehit_time = 0.1
		hitbox_break_guards = false
		if animatedSprite.frame >= 2 and animatedSprite.frame < 6:
			hitbox_upleft = Vector2( - 32, - 28)
			hitbox_downright = Vector2(50, 5)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
			
	if animatedSprite.animation == "saber_2":
		hitbox_damage = 4
		hitbox_damage_boss = 8
		hitbox_damage_weakness = 24
		hitbox_rehit_time = 0.1
		hitbox_break_guards = false
		if animatedSprite.frame >= 1 and animatedSprite.frame < 2:
			hitbox_upleft = Vector2( - 8, - 35)
			hitbox_downright = Vector2(37, -3)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 2 and animatedSprite.frame < 3:
			hitbox_upleft = Vector2( - 6, - 35)
			hitbox_downright = Vector2(64, 22)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
			hitbox_upleft = Vector2( - 39, - 33)
			hitbox_downright = Vector2(64, 22)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 4 and animatedSprite.frame < 5:
			hitbox_upleft = Vector2( - 39, - 5)
			hitbox_downright = Vector2(35, 23)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 5 and animatedSprite.frame < 6:
			hitbox_upleft = Vector2( - 39, - 5)
			hitbox_downright = Vector2(-10, 19)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
			
	if animatedSprite.animation == "saber_3":
		hitbox_damage = 12
		hitbox_damage_boss = 8
		hitbox_damage_weakness = 24
		hitbox_rehit_time = 0.2
		hitbox_break_guards = true
		if animatedSprite.frame >= 1 and animatedSprite.frame < 2:
			hitbox_upleft = Vector2( - 30, -3)
			hitbox_downright = Vector2(49, 22)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 2 and animatedSprite.frame < 4:
			hitbox_upleft = Vector2(12, -63)
			hitbox_downright = Vector2(69, 23)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
			hitbox_upleft = Vector2( -23, 0)
			hitbox_downright = Vector2(12, 23)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 4 and animatedSprite.frame < 5:
			hitbox_upleft = Vector2( 12, - 63)
			hitbox_downright = Vector2(53, -23)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 5 and animatedSprite.frame < 6:
			hitbox_upleft = Vector2( 12, - 63)
			hitbox_downright = Vector2(35, -23)
			spawn_hitbox(hitbox_upleft, hitbox_downright)

	if animatedSprite.animation == "saber_shot":
		hitbox_damage = 12
		hitbox_damage_boss = 8
		hitbox_damage_weakness = 24
		hitbox_rehit_time = 0.2
		hitbox_break_guards = true
		if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
			hitbox_upleft = Vector2( - 19, - 44)
			hitbox_downright = Vector2(45, 1)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 4 and animatedSprite.frame < 6:
			hitbox_upleft = Vector2( - 13, - 47)
			hitbox_downright = Vector2(69, 27)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 6 and animatedSprite.frame < 8:
			hitbox_upleft = Vector2(12, 7)
			hitbox_downright = Vector2(63, 27)
			spawn_hitbox(hitbox_upleft, hitbox_downright)

	reset_hitbox()

func end_saber_state():
	if animatedSprite.animation == "saber_1":
		return animatedSprite.frame >= 9
	if animatedSprite.animation == "saber_2":
		return animatedSprite.frame >= 10
	if animatedSprite.animation == "saber_3":
		return animatedSprite.frame >= 13
	if animatedSprite.animation == "saber_shot_normal":
		return animatedSprite.frame >= 13
	if animatedSprite.animation == "saber_shot_normal2":
		return animatedSprite.frame >= 13
	if animatedSprite.animation == "saber_shot":
		return animatedSprite.frame >= 11
	return false

func is_in_buffer_window() -> bool:
	if animatedSprite.animation == "saber_1" and animatedSprite.frame >= 6 - buffer_window_threshold:
		return true
	if animatedSprite.animation == "saber_2" and animatedSprite.frame >= 6 - buffer_window_threshold:
		return true
	if animatedSprite.animation == "saber_shot_normal" and animatedSprite.frame >= 11 - buffer_window_threshold:
		return true
	if animatedSprite.animation == "saber_shot_normal2" and animatedSprite.frame >= 11 - buffer_window_threshold:
		return true
	return false

func should_add_saber_combo():
	if animatedSprite.animation == "saber_shot_normal":
		return animatedSprite.frame >= 11
	if animatedSprite.animation == "saber_shot_normal2":
		return animatedSprite.frame >= 11
	if animatedSprite.animation == "saber_1":
		return animatedSprite.frame >= 6
	if animatedSprite.animation == "saber_2":
		return animatedSprite.frame >= 6
	if animatedSprite.animation == "saber_3":
		return false
	if animatedSprite.animation == "saber_shot":
		return false
	return false

func set_saber_animations():
	if character.is_on_floor():
		if slashes == 0:
			if not character.get_action_pressed("move_down") and not character.weaponget:
				animatedSprite.animation = "saber_1"
				saber_sound.play()
			elif character.get_action_pressed("move_down") and not character.weaponget:
				animatedSprite.animation = "saber_shot_normal"
				if use_shingetsurin:
					create_shingetsurin(global_position)
					shingetsurin_sound.play()
				else:
					create_zbuster(global_position)
					zbuster_sound.play()
			elif character.weaponget:
				animatedSprite.animation = "saber_1"
				saber_sound.play()
		if slashes == 1:
			if not character.get_action_pressed("move_down") and not character.weaponget:
				animatedSprite.animation = "saber_2"
				saber2_sound.play()
			elif character.get_action_pressed("move_down") and not character.weaponget:
				animatedSprite.animation = "saber_shot_normal2"
				if use_shingetsurin:
					create_shingetsurin(global_position)
					shingetsurin_sound.play()
				else:
					create_zbuster(global_position)
					zbuster_sound.play()
			elif character.weaponget:
				animatedSprite.animation = "saber_2"
				saber2_sound.play()
		if slashes == 2:
			if not character.get_action_pressed("move_down") and not character.weaponget:
				animatedSprite.animation = "saber_3"
				saber3_sound.play()
			elif character.get_action_pressed("move_down") and not character.weaponget:
				animatedSprite.animation = "saber_shot"
				swordwave_sound.play()
				create_swordwave(global_position)
			elif character.weaponget:
				animatedSprite.animation = "saber_3"
				saber3_sound.play()
				
	slashes += 1

func create_zbuster(ground_position) -> void :
	var instance = zbuster.instance()
	ground_position.y += -9
	instance.damage = CharacterManager.z_buster_base_damage * hitbox_extra_damage
	instance.damage_to_bosses = CharacterManager.z_buster_base_damage * hitbox_extra_damage_boss
	instance.damage_to_weakness = CharacterManager.z_buster_base_damage * hitbox_extra_damage_weakness
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func create_swordwave(ground_position) -> void :
	var instance = swordwave.instance()
	ground_position.y += -9
	instance.damage = CharacterManager.z_buster_base_damage * hitbox_extra_damage * 2
	instance.damage_to_bosses = CharacterManager.z_buster_base_damage * hitbox_extra_damage_boss * 2
	instance.damage_to_weakness = CharacterManager.z_buster_base_damage * hitbox_extra_damage_weakness * 2
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func create_shingetsurin(ground_position) -> void :
	var instance = shingetsurin.instance()
	ground_position.y += -9
	instance.damage = CharacterManager.z_buster_base_damage * hitbox_extra_damage * 2
	instance.damage_to_bosses = CharacterManager.z_buster_base_damage * hitbox_extra_damage_boss * 2
	instance.damage_to_weakness = CharacterManager.z_buster_base_damage * hitbox_extra_damage_weakness * 2
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.set_creator(creator)
	instance.call_deferred("initialize", get_facing_direction())

func _StartCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		return false
	var saber_charge = character.get_node_or_null("Charge")
	if saber_charge != null and saber_charge.get_charge_level() >= 1:
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
		if not _animation == "saber_1" and not _animation == "saber_2" and not _animation == "saber_3" and not _animation == "saber_shot" and not _animation == "saber_shot_normal" and not _animation == "saber_shot_normal2":
			return true
		if end_saber_state():
			return true
	else:
		return true
	return false

func _Setup() -> void :
	update_bonus_horizontal_only_conveyor()
	changed_animation = false
	slashing = false
	slashes = 0
	input_buffer = []
	set_saber_animations()

func _Update(_delta: float) -> void :
	hitbox_and_position()
	
	if is_in_buffer_window() and character.get_action_just_pressed(actions[0]):
		input_buffer.append(actions[0])
		
	if should_add_saber_combo() and input_buffer.size() > 0:
		input_buffer.pop_front()
		set_saber_animations()
	
	force_movement(0)
	
	process_gravity(_delta)
	update_bonus_horizontal_only_conveyor()

func change_animation_if_falling(_s) -> void :
	pass

func _Interrupt():
	._Interrupt()
	slashes = 0
	input_buffer = []
	character.play_animation("saber_recover")
	if is_instance_valid(current_hitbox):
		current_hitbox.queue_free()
