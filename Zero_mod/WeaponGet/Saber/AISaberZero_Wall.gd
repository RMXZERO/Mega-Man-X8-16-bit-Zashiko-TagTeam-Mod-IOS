extends WallSlideZero

export  var saber_hitbox: Resource = preload("res://Zero_mod/Player/Hitboxes/Saber_Hitbox.tscn")
var current_hitbox = null
var hitbox_upleft = Vector2(0, 0)
var hitbox_downright = Vector2(0, 0)
var hitbox_damage = 0
var hitbox_damage_boss = 0
var hitbox_damage_weakness = 0
var hitbox_break_guard_value = 0.25
var hitbox_break_guards: bool = false
var hitbox_rehit_time = 0.05

var hitbox_upgraded: bool = false
var hitbox_extra_damage = 1
var hitbox_extra_damage_boss = 1
var hitbox_extra_damage_weakness = 1
var hitbox_extra_break_guard_value = 1

var deflectable: bool = false
var hitbox_extra_scale = 1
export  var upgraded: = false
onready var animatedSprite = character.get_node("animatedSprite")
onready var saber_sound = get_node("saber")
onready var arm_cannon = character.get_node("Shot")

var current_weapon_index: = 0
var weapons = []
var current_weapon
var _listening_to_inputs_start: bool = true
var interrupted_cutscene: bool = false
var slashing: bool = false
var slashes = 0

var vertical_last = 0

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
		current_hitbox.name = "OpticShieldCharged"
	elif arm_cannon.current_weapon.name == "SqueezeBomb":
		current_hitbox.name = "SqueezeBombCharged"
	elif arm_cannon.current_weapon.name == "DarkArrow":
		current_hitbox.name = "DarkArrowCharged"
	elif arm_cannon.current_weapon.name == "ThunderDancer":
		current_hitbox.name = "ThunderDancerCharged"
	elif arm_cannon.current_weapon.name == "BlastLauncher":
		current_hitbox.name = "BlastLaunchCharged"
	elif arm_cannon.current_weapon.name == "CrystalBouncer":
		current_hitbox.name = "CrystalBouncerCharged"
	elif arm_cannon.current_weapon.name == "DriftDiamond":
		current_hitbox.name = "DriftDiamondCharged"
	elif arm_cannon.current_weapon.name == "FireDash":
		current_hitbox.name = "FireDashCharged"
	else:
		CharacterManager.set_saberX8_colors(animatedSprite)
		current_hitbox.name = "Saber"

func reset_hitbox():
	hitbox_upleft = Vector2(0, 0)
	hitbox_downright = Vector2(0, 0)
	hitbox_damage = 0
	hitbox_damage_boss = 0
	hitbox_damage_weakness = 0
	hitbox_break_guard_value = 0.25
	hitbox_break_guards = false
	hitbox_rehit_time = 0.05
	
func spawn_hitbox(_hitbox_upleft: Vector2, _hitbox_downright: Vector2):
	current_hitbox = saber_hitbox.instance()
	add_child(current_hitbox)
	hitbox_name()
	var facing_direction = get_facing_direction()
	if facing_direction == - 1:
		var temp_upleft = Vector2( - _hitbox_downright.x, _hitbox_upleft.y)
		var temp_downright = Vector2( - _hitbox_upleft.x, _hitbox_downright.y)
		current_hitbox.set_hitbox_corners(temp_upleft, temp_downright)
	else:
		current_hitbox.set_hitbox_corners(_hitbox_upleft, _hitbox_downright)
		
	current_hitbox.damage = hitbox_damage * hitbox_extra_damage
	current_hitbox.damage_to_bosses = hitbox_damage_boss * hitbox_extra_damage_boss
	current_hitbox.damage_to_weakness = hitbox_damage_weakness * hitbox_extra_damage_weakness
	current_hitbox.break_guard_damage = hitbox_break_guard_value * hitbox_extra_break_guard_value
	current_hitbox.break_guards = hitbox_break_guards
	current_hitbox.saber_rehit = hitbox_rehit_time
	current_hitbox.upgraded = hitbox_upgraded
	current_hitbox.scale *= hitbox_extra_scale
	
	current_hitbox.deflectable = deflectable

func hitbox_and_position():
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
	return animatedSprite.frame >= 8

func should_add_saber_combo():
	return animatedSprite.frame >= 6

func set_saber_animations():
	animatedSprite.animation = "saber_slide"
	animatedSprite.frame = 0
	saber_sound.play()
	
func _StartCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		return false
	if get_action_just_pressed(actions[0]) and character.is_executing("WallSlide"):

		return true
	return false
	
func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		if end_saber_state():
			return true
		if character.is_on_floor():
			return true
		if not character.is_in_reach_for_walljump():
			return true
		if get_pressed_direction() != character.is_in_reach_for_walljump():
			return true
		if get_pressed_direction() == 0:
			return true
	else:
		return true
	return false

func _Setup() -> void :
	character.velocity.y = vertical_last
	set_saber_animations()

func _Update(_delta: float) -> void :
	hitbox_and_position()
	if should_add_saber_combo():
		if character.get_action_just_pressed(actions[0]):
			set_saber_animations()

	character.set_horizontal_speed(horizontal_speed * wallgrab_direction)
	if delay_has_expired():
		emit_particles(particles, true)
		character.set_vertical_speed(jump_velocity)

func change_animation_if_falling(_s) -> void :
	animatedSprite.animation = "fall"

func _Interrupt():
	slashes = 0
	if is_instance_valid(current_hitbox):
		current_hitbox.queue_free()
	if character.get_vertical_speed() > 0:
		character.set_vertical_speed(40)
	character.set_horizontal_speed(0)
	emit_particles(particles, false)
	animatedSprite.animation = "slide"
	animatedSprite.frame = 3

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

