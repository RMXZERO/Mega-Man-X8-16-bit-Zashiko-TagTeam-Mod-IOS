extends WeaponGetZero

export var layer: bool = false
onready var weaponget_betazero = preload("res://Zero_mod/WeaponGet/WeaponGetSprite/weaponget_zero.tres")
onready var weaponget_zerox6 = preload("res://Zero_mod/WeaponGet/WeaponGetSprite/weaponget_zerox6.tres")
onready var weaponget_zerox8 = preload("res://Zero_mod/WeaponGet/WeaponGetSprite/weaponget_zerox8.tres")
onready var weaponget_layer = preload("res://Zero_mod/WeaponGet/WeaponGetSprite/weaponget_layer.tres")
onready var zero_material: Material = preload("res://Zero_mod/X8/Sprites/ZeroX8_Material_Shader.tres")
onready var layer_material: Material = preload("res://Zero_mod/X8/LayerSprites/Layer_Material_Shader.tres")
var less_buggy_pressed_dir: int = 0

func _ready():
	is_current_player = true
	CharacterManager.weaponget = true
	weaponget = true
	equip_weapon_get_zero_parts()
	Input.action_release("dash_emulated")
	Input.action_release("fire_emulated")
	Input.action_release("alt_fire_emulated")
	Input.action_release("up_emulated")
	Input.action_release("left_emulated")
	Input.action_release("right_emulated")
	Input.action_release("down_emulated")
	Input.action_release("jump_emulated")
	less_buggy_pressed_dir = 0
	animatedSprite.material = zero_material
	CharacterManager.set_zeroX8_colors(animatedSprite)
	if layer:
		animatedSprite.frames = weaponget_layer
		saber_node.normal_sprites = weaponget_layer
		saber_node.arm_pointing_sprites = weaponget_layer
		animatedSprite.material = layer_material
		CharacterManager.set_layer_colors(animatedSprite)
	if not layer and not CharacterManager.betazero_activated:
		animatedSprite.frames = weaponget_zerox8
		saber_node.normal_sprites = weaponget_zerox8
		saber_node.arm_pointing_sprites = weaponget_zerox8
	if not layer and CharacterManager.betazero_activated:
		animatedSprite.frames = weaponget_betazero
		saber_node.normal_sprites = weaponget_betazero
		saber_node.arm_pointing_sprites = weaponget_betazero
	if not layer and CharacterManager.betazero_activated and CharacterManager.weaponget_zero:
		animatedSprite.frames = weaponget_zerox6
		saber_node.normal_sprites = weaponget_zerox6
		saber_node.arm_pointing_sprites = weaponget_zerox6

func has_just_pressed_up() -> bool:
	return get_action_just_pressed("up_emulated")

func has_just_pressed_down() -> bool:
	return get_action_just_pressed("down_emulated")

func has_just_pressed_left() -> bool:
	return get_action_just_pressed("left_emulated")

func has_just_pressed_right() -> bool:
	return get_action_just_pressed("right_emulated")

func check_for_dash() -> void :
	if get_action_just_pressed("dash_emulated"):
		Event.emit_signal("input_dash")

func get_action_pressed(action) -> bool:
	if listening_to_inputs:
		return Input.is_action_pressed(action)
	return false

func get_just_pressed_axis() -> int:
	return less_buggy_pressed_dir

func get_pressed_axis() -> int:
	return less_buggy_pressed_dir

func _input(event: InputEvent) -> void :
	if event.is_action_pressed("right_emulated"):
		less_buggy_pressed_dir = 1
	elif event.is_action_released("right_emulated"):
		less_buggy_pressed_dir = 0
	if event.is_action_pressed("left_emulated"):
		less_buggy_pressed_dir = - 1
	elif event.is_action_released("left_emulated"):
		less_buggy_pressed_dir = 0

func equip_parts(collectible: String):
	pass

func is_full_armor() -> String:
	return "no_armor"

func _Update(_delta: float) -> void :
	pass

func equip_weapon_get_zero_parts():
	spike_invincibility = true
	var dash = get_node("Dash")
	var airdash = get_node("AirDash")
	var saberdash = get_node("SaberDash")
	var airjump = get_node("AirJump")
	var fall = get_node("Fall")
	dash.invulnerability_duration = 0
	airdash.max_airdashes = 1
	airjump.set_max_air_jumps(1)
	airjump.upgraded = false
	fall.upgraded = false
	
	dash.upgraded = false
	airdash.upgraded = false
	dash.invulnerability_duration = 0.0
	airdash.invulnerability_duration = 0.0

	dash.get_node("particles2D").texture = load("res://Zero_mod/Effects/follow_shot_hide.png")
	airdash.get_node("particles2D").texture = load("res://Zero_mod/Effects/follow_shot_hide.png")
	
	var lifesteal = get_node("LifeSteal")
	lifesteal.activate()
	lifesteal.first_decay = 0.5
	lifesteal.lifesteal_decay = 0.5
	lifesteal.minimum_time_between_heals = 0.2

	var dmg = get_node("Damage")
	dmg.active = false
	dmg.damage_reduction = 50
	dmg.prevent_knockbacks = false
	dmg.conflicting_moves = ["Death", "WallSlide", "Ride"]
	
	dash.horizontal_velocity = 300
	airdash.horizontal_velocity = 300
	saberdash.horizontal_velocity = 300
	saber_jump.horizontal_velocity = 300
	saber_jump.dashjump_speed = 300
	get_node("SaberJump").horizontal_velocity = 300
	get_node("DashJump").horizontal_velocity = 300
	get_node("DashWallJump").horizontal_velocity = 300
	airjump.dashjump_speed = 300
	fall.dashjump_speed = 300
	skill_rasetsusen.dashjump_speed = 300
	
	var dmg_multiplikator = 1.0
	var saber_nodes = [
		get_node("SaberCombo"), 
		get_node("SaberDash"), 
		get_node("SaberJump"), 
		get_node("SaberCharge"), 
		get_node("SaberWall"), 
		get_node("Juuhazan"), 
		get_node("Rasetsusen"), 
		get_node("Raikousen"), 
		get_node("Youdantotsu"), 
		get_node("Hyouryuushou"), 
		get_node("Enkoujin")
	]
	for _saber_node in saber_nodes:
		_saber_node.hitbox_upgraded = true
		_saber_node.hitbox_extra_damage = dmg_multiplikator
		_saber_node.hitbox_extra_damage_boss = dmg_multiplikator
		_saber_node.hitbox_extra_damage_weakness = dmg_multiplikator
		_saber_node.hitbox_extra_break_guard_value = dmg_multiplikator
		
	get_node("Youdantotsu").hitbox_upgraded = true
	get_node("Youdantotsu").start_speed = 500
	get_node("Raikousen").start_speed = 900
	get_node("Rasetsusen").hitbox_radius = 55
	for _saber_node in saber_nodes:
		if _saber_node != get_node("Youdantotsu"):
			_saber_node.hitbox_upgraded = true
	get_node("Rasetsusen").upgraded = true
	get_node("Rasetsusen").cast_time_max = 0.5
	saber_combo.use_shingetsurin = false

	saber_combo.deflectable = true
	saber_dash.deflectable = true
	saber_jump.deflectable = true
	saber_wall.deflectable = true
		
	skill_juuhazan.deflectable = true
	skill_rasetsusen.deflectable = true
	skill_raikousen.deflectable = true
	skill_youdantotsu.deflectable = true
	skill_hyouryuushou.deflectable = true
	skill_enkoujin.deflectable = true
		
	saber_combo.saber_hitbox = rekkyoudan_hitbox
	saber_dash.saber_hitbox = rekkyoudan_hitbox
	saber_jump.saber_hitbox = rekkyoudan_hitbox
	saber_wall.saber_hitbox = rekkyoudan_hitbox

func equip_black_zero_parts():
	equip_weapon_get_zero_parts()
	
func equip_awakened_zero_parts() -> void :
	equip_weapon_get_zero_parts()

func equip_awakened_zero_up_parts() -> void :
	equip_weapon_get_zero_parts()

func equip_axl_flameburner_parts() -> void :
	equip_weapon_get_zero_parts()

func equip_cancel_axl_flameburner_parts() -> void :
	equip_weapon_get_zero_parts()




