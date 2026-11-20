extends FallZero

export  var saber_hitbox: Resource = preload("res://Zero_mod/Player/Hitboxes/Saber_Hitbox.tscn")
onready var effect_animation = preload("res://Zero_mod/X8/Sprites/zbuster/object/object.tres")
var current_hitbox = null
var hitbox_upleft = Vector2(0, 0)
var hitbox_downright = Vector2(0, 0)
var hitbox_damage = 0
var hitbox_damage_boss = 0
var hitbox_damage_weakness = 0
var hitbox_break_guard_value = 0.4
var hitbox_break_guards: bool = false
var hitbox_rehit_time = 0.05

var hitbox_upgraded: bool = false
var hitbox_extra_damage = 1
var hitbox_extra_damage_boss = 1
var hitbox_extra_damage_weakness = 1
var hitbox_extra_break_guard_value = 1

var deflectable: bool = false
var hitbox_extra_scale = 1
onready var animatedSprite = character.get_node("animatedSprite")
onready var saber_sound = get_node("saber")
onready var dive_sound = get_node("dive")
onready var sentsuizan_land_sound = get_node("land")
onready var break_sound = get_node("break")
onready var arm_cannon = character.get_node("Shot")

var current_weapon_index: = 0
var weapons = []
var current_weapon
var _listening_to_inputs_start: bool = true
var interrupted_cutscene: bool = false
var slashing: bool = false
var slashes = 0
var landed: bool = false

var vertical_last = 0
var screenshake: bool = false
var end_state: bool = false
var is_charge_saber: bool = false

func _ready() -> void :
	if active:
		Event.listen("charged_shot_release", self, "charged_saber_release")

func saber_color() -> void:
	if arm_cannon.current_weapon.name == "CrystalBouncer" or CharacterManager.rekkyoudan_active:
		saber_rekkyoudan_on()
	else:
		saber_rekkyoudan_off()

func saber_rekkyoudan_on() -> void:
	character.saber_combo.deflectable = true
	character.saber_dash.deflectable = true
	character.saber_jump.deflectable = true
	character.saber_wall.deflectable = true
	deflectable = true
	
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
	deflectable = false
	
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
		current_hitbox.name = "SaberCharged"

func reset_hitbox():
	hitbox_upleft = Vector2(0, 0)
	hitbox_downright = Vector2(0, 0)
	hitbox_damage = 0
	hitbox_damage_boss = 0
	hitbox_damage_weakness = 0
	hitbox_break_guard_value = 0.4
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
	
	if animatedSprite.animation == "charge_sentsuizan":
		hitbox_damage = 12
		hitbox_damage_boss = 12
		hitbox_damage_weakness = 24
		hitbox_break_guards = true
		hitbox_rehit_time = 0.1
		if character.saber_node.current_weapon.name == "Sigma-Blade":
			if animatedSprite.frame >= 2 and animatedSprite.frame < 7:
				hitbox_upleft = Vector2(17, - 22)
				hitbox_downright = Vector2(125, 52)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
		else:
			if animatedSprite.frame >= 2 and animatedSprite.frame < 7:
				hitbox_upleft = Vector2(17, - 22)
				hitbox_downright = Vector2(83, 52)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
		return
	
	if character.saber_node.current_weapon.name == "D-Glaive":
		hitbox_damage = 6
		hitbox_damage_boss = 6
		hitbox_damage_weakness = 12
		hitbox_break_guards = true
		hitbox_rehit_time = 0.0125
		if animatedSprite.animation == "charge_saber_jump":
			if animatedSprite.frame >= 1 and animatedSprite.frame < 2:
				hitbox_upleft = Vector2( - 62, - 85)
				hitbox_downright = Vector2( - 32, - 55)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2( - 97, - 85)
				hitbox_downright = Vector2( - 62, -10)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2( - 32, - 133)
				hitbox_downright = Vector2(59, - 85)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 2 and animatedSprite.frame < 3:
				hitbox_upleft = Vector2(29, - 85)
				hitbox_downright = Vector2(59, - 55)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2(59, - 85)
				hitbox_downright = Vector2(127, 10)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
		if animatedSprite.animation == "charge_saber_land":
			if animatedSprite.frame >= 1 and animatedSprite.frame < 2:
				hitbox_upleft = Vector2( - 62, - 75)
				hitbox_downright = Vector2( - 32, - 45)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2( - 97, - 75)
				hitbox_downright = Vector2( - 62, 0)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
				hitbox_upleft = Vector2( - 32, - 123)
				hitbox_downright = Vector2(59, - 75)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 2 and animatedSprite.frame < 3:
				hitbox_upleft = Vector2(29, - 75)
				hitbox_downright = Vector2(59, - 45)
				spawn_hitbox(hitbox_upleft, hitbox_downright)
			elif animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2(59, - 75)
				hitbox_downright = Vector2(127, 20)
				spawn_hitbox(hitbox_upleft, hitbox_downright)

		if is_charge_saber:
			hitbox_damage = 36
			hitbox_damage_boss = 36
			hitbox_damage_weakness = 48
			hitbox_rehit_time = 0.5
			hitbox_break_guards = true
			if animatedSprite.animation == "charge_saber_jump":
				if animatedSprite.frame >= 4 and animatedSprite.frame < 12:
					hitbox_upleft = Vector2(65, - 79)
					hitbox_downright = Vector2(141, 45)
					spawn_hitbox(hitbox_upleft, hitbox_downright)
					hitbox_upleft = Vector2(65, 45)
					hitbox_downright = Vector2(141, 74)
					spawn_hitbox(hitbox_upleft, hitbox_downright)
			if animatedSprite.animation == "charge_saber_land":
				if animatedSprite.frame >= 4 and animatedSprite.frame < 12:
					hitbox_upleft = Vector2(65, - 79)
					hitbox_downright = Vector2(141, 45)
					spawn_hitbox(hitbox_upleft, hitbox_downright)

	elif not character.saber_node.current_weapon.name == "D-Glaive":
		hitbox_damage = 6
		hitbox_damage_boss = 6
		hitbox_damage_weakness = 12
		hitbox_rehit_time = 0.1
		hitbox_break_guards = true
		if animatedSprite.animation == "charge_saber_jump":
			if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 19, - 54)
				hitbox_downright = Vector2(45, 11)
			if animatedSprite.frame >= 4 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2( - 13, - 57)
				hitbox_downright = Vector2(69, 37)
			if animatedSprite.frame >= 6 and animatedSprite.frame < 8:
				hitbox_upleft = Vector2(12, -3)
				hitbox_downright = Vector2(63, 17)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
	
		if animatedSprite.animation == "charge_saber_land":
			if animatedSprite.frame >= 3 and animatedSprite.frame < 4:
				hitbox_upleft = Vector2( - 19, - 44)
				hitbox_downright = Vector2(45, 1)
			if animatedSprite.frame >= 4 and animatedSprite.frame < 6:
				hitbox_upleft = Vector2( - 13, - 47)
				hitbox_downright = Vector2(69, 27)
			if animatedSprite.frame >= 6 and animatedSprite.frame < 8:
				hitbox_upleft = Vector2(12, 7)
				hitbox_downright = Vector2(63, 27)
			spawn_hitbox(hitbox_upleft, hitbox_downright)
		
		if is_charge_saber:
			hitbox_damage = 36
			hitbox_damage_boss = 36
			hitbox_damage_weakness = 48
			hitbox_rehit_time = 0.5
			hitbox_break_guards = true
			if animatedSprite.animation == "charge_saber_jump":
				if animatedSprite.frame >= 3 and animatedSprite.frame < 13:
					hitbox_upleft = Vector2(-10, -29)
					hitbox_downright = Vector2(141, 37)
					spawn_hitbox(hitbox_upleft, hitbox_downright)
					hitbox_upleft = Vector2(50, -122)
					hitbox_downright = Vector2(127, -29)
					spawn_hitbox(hitbox_upleft, hitbox_downright)
					hitbox_upleft = Vector2(15, -47)
					hitbox_downright = Vector2(50, -29)
					spawn_hitbox(hitbox_upleft, hitbox_downright)
			
					hitbox_upleft = Vector2(-10, 37)
					hitbox_downright = Vector2(132, 74)
					spawn_hitbox(hitbox_upleft, hitbox_downright)
			if animatedSprite.animation == "charge_saber_land":
				if animatedSprite.frame >= 3 and animatedSprite.frame < 13:
					hitbox_upleft = Vector2(-10, -19)
					hitbox_downright = Vector2(141, 27)
					spawn_hitbox(hitbox_upleft, hitbox_downright)
					hitbox_upleft = Vector2(50, -112)
					hitbox_downright = Vector2(127, -19)
					spawn_hitbox(hitbox_upleft, hitbox_downright)
					hitbox_upleft = Vector2(15, -37)
					hitbox_downright = Vector2(50, -19)
					spawn_hitbox(hitbox_upleft, hitbox_downright)
		
	reset_hitbox()

func _StartCondition() -> bool:
	return false
	
func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		if not _animation == "charge_saber_land" and not _animation == "charge_saber_jump" and not _animation == "charge_sentsuizan":
			return true
		if end_saber_state():
			return true
	return false

var effect: AnimatedSprite
var effect_transparency: float = 0.75
onready var effect_material: Material = preload("res://Zero_mod/X8/Sprites/ZeroX8_Material_Shader.tres")
func effect_emit(_animation, new_scale: float, new_position_x: float, new_position_y: float, flip_h: bool, new_z_index: float) -> void :
	effect = AnimatedSprite.new()
	add_child(effect)
	effect.frames = effect_animation
	effect.animation = _animation
	effect.frame = animatedSprite.frame
	effect.playing = true
	effect.global_position.x = global_position.x + new_position_x * character.get_facing_direction()
	effect.global_position.y = global_position.y + new_position_y
	effect.modulate = Color(1, 1, 1, effect_transparency)
	effect.scale = animatedSprite.scale * new_scale
	effect.z_index = animatedSprite.z_index + 1 + new_z_index
	effect.centered = animatedSprite.centered
	effect.offset.x = animatedSprite.offset.x - 3
	effect.rotation_degrees = animatedSprite.rotation_degrees
	if flip_h:
		effect.flip_h = true
		effect.flip_v = animatedSprite.flip_v
	else:
		effect.flip_h = animatedSprite.flip_h
		effect.flip_v = animatedSprite.flip_v
	
	effect.material = effect_material
	CharacterManager.set_zeroX8_colors(effect)
	if CharacterManager.betazero_activated and CharacterManager.weaponget_zero:
		set_new_colors_on_shader_parameters(effect, arm_cannon.current_weapon.get_palette())

func set_new_colors_on_shader_parameters(object, new_colors) -> void :
	if arm_cannon.current_weapon.name == "OpticShield" or \
	arm_cannon.current_weapon.name == "SqueezeBomb" or \
	arm_cannon.current_weapon.name == "DarkArrow" or \
	arm_cannon.current_weapon.name == "ThunderDancer" or \
	arm_cannon.current_weapon.name == "BlastLauncher" or \
	arm_cannon.current_weapon.name == "CrystalBouncer" or \
	arm_cannon.current_weapon.name == "DriftDiamond" or \
	arm_cannon.current_weapon.name == "FireDash":
		object.material.set_shader_param("R_SaberColor1", new_colors[0])
		object.material.set_shader_param("R_SaberColor2", new_colors[1])
		object.material.set_shader_param("R_SaberColor3", new_colors[2])
		object.material.set_shader_param("R_SaberColor4", new_colors[3])
		object.material.set_shader_param("R_SaberColor5", new_colors[4])

func charged_saber_release(charge_level) -> void :
	if not character.has_control():
		Log("Couldn\'t charged fire, character has no control")
		return
	if not CharacterManager.extra_saber_combo:
		return
	if character.is_executing("Intro") or \
	character.is_executing("Finish") or \
	character.is_executing("Tenshouha") or \
	character.is_executing("Juuhazan") or \
	character.is_executing("Rasetsusen") or \
	character.is_executing("Raikousen") or \
	character.is_executing("Youdantotsu") or \
	character.is_executing("Hyouryuushou") or \
	character.is_executing("Enkoujin") or \
	character.is_executing("Genmuzero") or \
	character.is_executing("Desperation") or \
	character.is_executing("Rekuhouha") or \
	character.is_executing("Ryuenjin") or \
	character.is_executing("Enkoujin_Extra"):
		return
		
	if charge_level >= 3:
		if not character.is_executing("Intro") and \
		not character.is_executing("Finish") and \
		not character.is_executing("WallSlide") and \
		not character.is_executing("SaberWall") and \
		not character.is_executing("Tenshouha") and \
		not character.is_executing("Juuhazan") and \
		not character.is_executing("Rasetsusen") and \
		not character.is_executing("Raikousen") and \
		not character.is_executing("Youdantotsu") and \
		not character.is_executing("Hyouryuushou") and \
		not character.is_executing("Enkoujin") and \
		not character.is_executing("Genmuzero") and \
		not character.is_executing("Desperation") and \
		not character.is_executing("Rekuhouha") and \
		not character.is_executing("Ryuenjin") and \
		not character.is_executing("Enkoujin_Extra"):
			if not CharacterManager.extra_saber_07:
				return
			if animatedSprite.frames.has_animation("charge_saber_land") and animatedSprite.frames.has_animation("charge_saber_jump"):
				is_charge_saber = true
				self.ExecuteOnce()
		
	elif charge_level <= 2:
		if not CharacterManager.extra_saber_06:
			return
		if animatedSprite.frames.has_animation("charge_saber_land") and animatedSprite.frames.has_animation("charge_sentsuizan"):
			self.ExecuteOnce()

func end_saber_state():
	return end_state

func set_saber_animations():
	if is_charge_saber:
		Tools.timer(0.5, "finish", self)
		if character.is_on_floor():
			animatedSprite.animation = "charge_saber_land"
			animatedSprite.frame = 0
			saber_sound.play()
		else:
			animatedSprite.animation = "charge_saber_jump"
			animatedSprite.frame = 0
			saber_sound.play()
	else:
		if character.is_on_floor():
			animatedSprite.animation = "charge_saber_land"
			animatedSprite.frame = 0
			saber_sound.play()
		else:
			animatedSprite.animation = "charge_sentsuizan"
			animatedSprite.frame = 0
			saber_sound.play()

func _Setup() -> void :
	if character.saber_node.current_weapon.name == "D-Glaive":
		if is_charge_saber:
			if character.is_on_floor():
				effect_emit("charge_saber",1 , 90 , -22, false , 0)
				effect_emit("charge_land",1 , 131 , 8, true, 1)
				effect_emit("charge_land",1 , 49 , 8, false, 1)
			else:
				effect_emit("charge_saber_air",1 ,90 , - 32, false, 0)
	
	else:
		if is_charge_saber:
			if character.is_on_floor():
				effect_emit("charge_saber",1.5 , 64 , -42, false , 0)
				effect_emit("charge_land",1.5 ,115 , -12, true, 1)
				effect_emit("charge_land",1.5 ,4 , -12, false, 1)
			else:
				effect_emit("charge_saber_air",1.5 ,64 , - 52, false, 0)
				
	landed = false
	end_state = false
	screenshake = false
	if vertical_last != 0:
		character.velocity.y = vertical_last
	set_saber_animations()
	if character.dashjumps_since_jump > 0:
		horizontal_velocity = character.saber_jump.dashjump_speed
	else:
		horizontal_velocity = 90

func finish() -> void :
	end_state = true

func _Update(_delta: float) -> void :
	hitbox_and_position()

	process_gravity(_delta)
	
	if is_charge_saber:
		if animatedSprite.animation == "charge_saber_land" or animatedSprite.animation == "charge_saber_jump":
			if animatedSprite.frame >= 4:
				if not screenshake:
					screenshake = true
					dive_sound.play()
					break_sound.play()
					Event.emit_signal("screenshake", 1000)
					
		if character.dashfall:
			set_movement_no_direction(character.saber_jump.dashjump_speed)
		else:
			set_movement_no_direction(horizontal_velocity)
					
		var animation_frame = animatedSprite.frame
		if character.is_on_floor():
			if not landed:
				animatedSprite.animation = "charge_saber_land"
				animatedSprite.frame = animation_frame
				landed = true
			set_movement_no_direction(0)
			update_bonus_horizontal_only_conveyor()
					
					
	else:
		if animatedSprite.animation == "charge_sentsuizan":
			if animatedSprite.frame >= 5 and not landed:
				animatedSprite.frame = 3
				force_movement(character.saber_jump.dashjump_speed * 1.5)
				character.set_vertical_speed(character.saber_jump.dashjump_speed * 3)
				
			if character.is_on_floor():
				if not landed:
					Tools.timer(0.5, "finish", self)
					landed = true
					sentsuizan_land_sound.play()
					break_sound.play()
					Event.emit_signal("screenshake", 1000)
					character.set_horizontal_speed(0)
					character.set_vertical_speed(0)
		if animatedSprite.animation == "charge_saber_land":
			character.set_horizontal_speed(0)
			if not landed:
				animatedSprite.speed_scale = 0.5
				Tools.timer(0.3, "finish", self)
				landed = true
					

func change_animation_if_falling(_s) -> void :
	animatedSprite.animation = "fall"

func _Interrupt():
	slashes = 0
	animatedSprite.speed_scale = 1
	is_charge_saber = false
	var _fall_node = character.get_node("Fall")
	_fall_node.horizontal_velocity = horizontal_velocity
	if character.is_on_floor():
		animatedSprite.animation = "recover"
	if is_instance_valid(current_hitbox):
		current_hitbox.queue_free()
	if is_instance_valid(effect):
		effect.queue_free()
		effect = null

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
	

