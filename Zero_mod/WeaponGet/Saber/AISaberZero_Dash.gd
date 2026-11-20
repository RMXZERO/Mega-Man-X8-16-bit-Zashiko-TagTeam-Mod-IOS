extends FallZero

export  var saber_hitbox: Resource = preload("res://Zero_mod/Player/Hitboxes/Saber_Hitbox.tscn")

onready var saber_sound: AudioStreamPlayer = $saber

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

var horizontal_speed = horizontal_velocity
var damping = 0.97

func hitbox_and_position():
	if animatedSprite.animation == "saber_dash":
		hitbox_damage = 6
		hitbox_damage_boss = 6
		hitbox_damage_weakness = 24
		hitbox_break_guards = true
		hitbox_rehit_time = 0.025
		if animatedSprite.frame >= 2 and animatedSprite.frame < 5:
			hitbox_upleft = Vector2(7, - 22)
			hitbox_downright = Vector2(83, 22)
			spawn_hitbox(hitbox_upleft, hitbox_downright)

	if animatedSprite.animation == "saber_dash2":
		hitbox_damage = 3
		hitbox_damage_boss = 3
		hitbox_damage_weakness = 24
		hitbox_rehit_time = 0.0125
		hitbox_break_guards = true
		if animatedSprite.frame >= 3 and animatedSprite.frame < 9:
			hitbox_upleft = Vector2( - 17, - 15)
			hitbox_downright = Vector2(95, 15)
			spawn_hitbox(hitbox_upleft, hitbox_downright)

	reset_hitbox()

func end_saber_state():
	if animatedSprite.animation == "ryuenjin":
		return animatedSprite.frame >= 20
	elif animatedSprite.animation == "saber_dash2":
		return animatedSprite.frame >= 12
	elif animatedSprite.animation == "genmuzero":
		return animatedSprite.frame >= 23
	elif animatedSprite.animation == "genmuzeroair":
		return animatedSprite.frame >= 23
	else:
		return animatedSprite.frame >= 10

func should_add_saber_combo():
	return false

func set_saber_animations():
	if not character.weaponget and character.get_action_pressed("move_down") and CharacterManager.extra_saber_combo and CharacterManager.extra_saber_02:
		animatedSprite.animation = "saber_dash2"
		saber_sound.play()
	else:
		animatedSprite.animation = "saber_dash"
		saber_sound.play()

func _StartCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		return false
	var saber_charge = character.get_node_or_null("Charge")
	if saber_charge != null and saber_charge.get_charge_level() >= 1:
		return false
	if not character.weaponget and character.get_action_pressed("move_up") and CharacterManager.extra_saber_combo and CharacterManager.extra_saber_03:
		return false
	if not executing:
		if _animation == "dash":
			return true
	return false
	
func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		if end_saber_state():
			return true
	else:
		return true
	return false

func _Setup() -> void :
	horizontal_speed = horizontal_velocity
	update_bonus_horizontal_only_conveyor()
	slashing = false
	set_saber_animations()

func damp_horizontal_speed(_delta: float) -> void :
	var reference_delta = 1.0 / 120
	var damping_factor = pow(damping, _delta / reference_delta)
	horizontal_speed *= damping_factor

func _Update(_delta: float) -> void :
	hitbox_and_position()
	force_movement(horizontal_speed)
	damp_horizontal_speed(_delta)

	
	update_bonus_horizontal_only_conveyor()

	if animatedSprite.animation == "saber_dash2":
		force_movement(horizontal_velocity)

func change_animation_if_falling(_s) -> void :
	pass

func _Interrupt():
	
	slashes = 0
	character.play_animation("saber_recover")
	if is_instance_valid(current_hitbox):
		current_hitbox.queue_free()
