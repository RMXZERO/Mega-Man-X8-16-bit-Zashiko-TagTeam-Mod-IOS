extends FallAxl

export  var saber_hitbox: Resource = preload("res://Zero_mod/Player/Hitboxes/Saber_Hitbox.tscn")

onready var saber_sound: AudioStreamPlayer = $saber
onready var saber2_sound: AudioStreamPlayer = $saber2
onready var saber3_sound: AudioStreamPlayer = $saber3

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
onready var fall = character.get_node("Fall")
onready var animatedSprite = character.get_node("animatedSprite")

var input_buffer = []
var buffer_window_threshold = 3
var slashing: bool = false
var slashes = 0

func _ready():
	animatedSprite.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished() -> void :
	ending_saber_state = true

func hitbox_name():
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
		if hitbox_break_guards:
			current_hitbox.name = "SaberCharged"
		else:
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
			hitbox_upleft = Vector2( - 32, - 21)
			hitbox_downright = Vector2(45, 9)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
			
	if animatedSprite.animation == "saber_2":
		hitbox_damage = 4
		hitbox_damage_boss = 8
		hitbox_damage_weakness = 24
		hitbox_rehit_time = 0.1
		hitbox_break_guards = false
		if animatedSprite.frame >= 1 and animatedSprite.frame < 2:
			hitbox_upleft = Vector2( - 12, - 33)
			hitbox_downright = Vector2(33, 1)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 2 and animatedSprite.frame < 3:
			hitbox_upleft = Vector2( - 22, - 33)
			hitbox_downright = Vector2(53, 22)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
			hitbox_upleft = Vector2( - 44, - 33)
			hitbox_downright = Vector2(53, 22)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 4 and animatedSprite.frame < 5:
			hitbox_upleft = Vector2( - 44, - 4)
			hitbox_downright = Vector2(31, 22)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 5 and animatedSprite.frame < 6:
			hitbox_upleft = Vector2( - 44, - 4)
			hitbox_downright = Vector2(-17, 22)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
			
	if animatedSprite.animation == "saber_3":
		hitbox_damage = 12
		hitbox_damage_boss = 8
		hitbox_damage_weakness = 24
		hitbox_rehit_time = 0.2
		hitbox_break_guards = true
		if animatedSprite.frame >= 1 and animatedSprite.frame < 2:
			hitbox_upleft = Vector2( - 34, 1)
			hitbox_downright = Vector2(45, 26)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 2 and animatedSprite.frame < 4:
			hitbox_upleft = Vector2( - 34, 1)
			hitbox_downright = Vector2(15, 26)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
			hitbox_upleft = Vector2( 15, - 60)
			hitbox_downright = Vector2(72, 26)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 4 and animatedSprite.frame < 5:
			hitbox_upleft = Vector2( 15, - 60)
			hitbox_downright = Vector2(56, -20)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 5 and animatedSprite.frame < 6:
			hitbox_upleft = Vector2( 15, - 60)
			hitbox_downright = Vector2(38, -24)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
			
	if animatedSprite.animation == "saber_jump":
		hitbox_damage = 4
		hitbox_damage_boss = 4
		hitbox_damage_weakness = 24
		hitbox_break_guards = false
		if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
			hitbox_upleft = Vector2( - 19, - 54)
			hitbox_downright = Vector2(45, 11)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 4 and animatedSprite.frame < 6:
			hitbox_upleft = Vector2( - 13, - 57)
			hitbox_downright = Vector2(69, 37)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 6 and animatedSprite.frame < 8:
			hitbox_upleft = Vector2(12, 17)
			hitbox_downright = Vector2(63, 37)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
	if animatedSprite.animation == "saber_land":
		hitbox_damage = 4
		hitbox_damage_boss = 4
		hitbox_damage_weakness = 24
		hitbox_break_guards = false
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

	if animatedSprite.animation == "saber_slide":
		hitbox_damage = 4
		hitbox_damage_boss = 4
		hitbox_damage_weakness = 24
		if animatedSprite.frame >= 1 and animatedSprite.frame < 2:
			hitbox_upleft = Vector2(2, - 37)
			hitbox_downright = Vector2(57, 5)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 2 and animatedSprite.frame < 4:
			hitbox_upleft = Vector2(9, - 35)
			hitbox_downright = Vector2(59, 29)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.frame >= 4 and animatedSprite.frame < 6:
			hitbox_upleft = Vector2(9, 6)
			hitbox_downright = Vector2(51, 29)
			spawn_hitbox(hitbox_upleft, hitbox_downright)

	reset_hitbox()

func end_saber_state():
	if animatedSprite.animation == "saber_1":
		return animatedSprite.frame >= 9
	if animatedSprite.animation == "saber_2":
		return animatedSprite.frame >= 10
	if animatedSprite.animation == "saber_3":
		return animatedSprite.frame >= 13
	if animatedSprite.animation == "saber_jump":
		return animatedSprite.frame >= 9
	if animatedSprite.animation == "saber_land":
		return animatedSprite.frame >= 9
	if animatedSprite.animation == "saber_slide":
		if character.is_on_floor():
			return true
		return animatedSprite.frame >= 9
	return false

func is_in_buffer_window() -> bool:
	if animatedSprite.animation == "saber_1" and animatedSprite.frame >= 6 - buffer_window_threshold:
		return true
	if animatedSprite.animation == "saber_2" and animatedSprite.frame >= 6 - buffer_window_threshold:
		return true
	if animatedSprite.animation == "saber_jump" and animatedSprite.frame >= 6 - buffer_window_threshold:
		return true
	if animatedSprite.animation == "saber_slide":
		return false
	return false

func should_add_saber_combo():
	if animatedSprite.animation == "saber_1":
		return animatedSprite.frame >= 6
	if animatedSprite.animation == "saber_2":
		return animatedSprite.frame >= 6
	if animatedSprite.animation == "saber_3":
		return false
	if animatedSprite.animation == "saber_jump":
		return animatedSprite.frame >= 6
	if animatedSprite.animation == "saber_slide":
		return false
	return false

func set_saber_animations():
	if not character.is_on_floor():
		if character.is_executing("WallSlide"):
			animatedSprite.animation = "saber_slide"
			animatedSprite.frame = 0
			saber_sound.play()
		else:
			animatedSprite.animation = "saber_jump"
			animatedSprite.frame = 0
			saber_sound.play()
	if character.is_on_floor():
		if slashes == 0:
			animatedSprite.animation = "saber_1"
			saber_sound.play()
		if slashes == 1:
			animatedSprite.animation = "saber_2"
			saber2_sound.play()
		if slashes == 2:
			animatedSprite.animation = "saber_3"
			saber3_sound.play()
	slashes += 1

func _StartCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation == "shot" or _animation == "shot_air" or _animation == "shot_slide" or _animation == "dodge" or _animation == "diagonal_dash":
		return false
	if _animation == "saber_1" or _animation == "saber_2" or _animation == "saber_3" or _animation == "saber_jump" or _animation == "saber_land" or _animation == "saber_slide":
		return false
	if not "Pistol" in arm_cannon.current_weapon.name:
		return false
	if not executing:
		return true
	return false
	
func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	var _animation = get_parent().get_animation()
	if not _animation == "saber_1" and not _animation == "saber_2" and not _animation == "saber_3" and not _animation == "saber_jump" and not _animation == "saber_land" and not _animation == "saber_slide":
		return true
	if end_saber_state():
		return true
	return false

func _Setup() -> void :
	update_bonus_horizontal_only_conveyor()
	changed_animation = false
	slashing = false
	slashes = 0
	input_buffer = []
	set_saber_animations()
	if character.dashjumps_since_jump > 0:
		horizontal_velocity = fall.dash_momentum
		character.dashjump_signal()
	else:
		horizontal_velocity = 90

func _Update(_delta: float) -> void :
	hitbox_and_position()
	
	if is_in_buffer_window() and character.get_action_just_pressed(actions[0]):
		input_buffer.append(actions[0])
		
	if should_add_saber_combo() and input_buffer.size() > 0:
		input_buffer.pop_front()
		set_saber_animations()
	
	if animatedSprite.animation == "saber_1" or animatedSprite.animation == "saber_2" or animatedSprite.animation == "saber_3":
		force_movement(0)
	
	if animatedSprite.animation == "saber_jump":
		if character.dashfall:
			set_movement_and_direction(fall.dash_momentum, _delta)
		else:
			set_movement_and_direction(horizontal_velocity, _delta)
	
	if animatedSprite.animation == "saber_slide":
		if CharacterManager.floppa_axl_activated:
			if character.get_action_pressed("move_down"):
				set_vertical_speed(90)
			else:
				set_vertical_speed(0)
		else:
			set_vertical_speed(90)
	
	var animation_frame = animatedSprite.frame
	if character.is_on_floor():
		if animatedSprite.animation == "saber_jump":
			animatedSprite.animation = "saber_land"
			animatedSprite.frame = animation_frame
		set_movement_no_direction(0)
	if not animatedSprite.animation == "saber_slide":
		process_gravity(_delta)
	update_bonus_horizontal_only_conveyor()

func change_animation_if_falling(_s) -> void :
	if not character.is_on_floor():
		animatedSprite.animation = "fall"
	else:
		animatedSprite.animation = "recover"

func _Interrupt():
	._Interrupt()
	slashes = 0
	input_buffer = []
	if is_instance_valid(current_hitbox):
		current_hitbox.queue_free()
