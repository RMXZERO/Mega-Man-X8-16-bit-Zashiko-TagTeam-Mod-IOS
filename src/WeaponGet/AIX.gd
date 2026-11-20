extends X

onready var alia_sprites: Resource = preload("res://src/Actors/Player/alia_sprites/alia.tres")
onready var alia_sprites_arm: Resource = preload("res://src/Actors/Player/alia_sprites/alia_arm.tres")
onready var infinite_x_sprites: Resource = preload("res://X_mod/InfiniteX/Sprites/InfiniteX.tres")
onready var infinite_x_sprites_arm: Resource = preload("res://X_mod/InfiniteX/Sprites/InfiniteX_leftarm.tres")

export var alia: bool = false
var less_buggy_pressed_dir: int = 0

func _ready():
	is_current_player = true
	CharacterManager.weaponget = true
	equip_hermes_arms_parts()
	Input.action_release("dash_emulated")
	Input.action_release("fire_emulated")
	Input.action_release("alt_fire_emulated")
	Input.action_release("up_emulated")
	Input.action_release("left_emulated")
	Input.action_release("right_emulated")
	Input.action_release("down_emulated")
	Input.action_release("jump_emulated")
	if alia:
		alia_weaponget()
	if not alia and not CharacterManager.use_old_sprite:
		x_x8_weaponget()
	if not alia and CharacterManager.infinite_x_activated and CharacterManager.use_old_sprite:
		infinite_x_weaponget()

func set_sprite():
	pass

func alia_weaponget():
	get_node("animatedSprite").frames = alia_sprites
	get_node("animatedSprite").get_node("head_armor").self_modulate = Color(1, 1, 1, 0)
	get_node("animatedSprite").get_node("body_armor").self_modulate = Color(1, 1, 1, 0)
	get_node("animatedSprite").get_node("arms_armor").self_modulate = Color(1, 1, 1, 0)
	get_node("animatedSprite").get_node("cannon_armor").self_modulate = Color(1, 1, 1, 0)
	get_node("animatedSprite").get_node("legs_armor").self_modulate = Color(1, 1, 1, 0)
	get_node("animatedSprite").get_node("ultimate_armor").frames = alia_sprites
	get_node("animatedSprite").get_node("ultimate_canon").frames = alia_sprites_arm
	get_node("Shot").normal_sprites = alia_sprites
	get_node("Shot").arm_pointing_sprites = alia_sprites_arm

	animatedSprite.material.set_shader_param("MainColor1", Color("#5c5c5c"))
	animatedSprite.material.set_shader_param("MainColor2", Color("#484848"))
	animatedSprite.material.set_shader_param("MainColor3", Color("#343434"))
#	animatedSprite.material.set_shader_param("MainColor4", Color("#D73252"))
#	animatedSprite.material.set_shader_param("MainColor5", Color("#78201e"))
#	animatedSprite.material.set_shader_param("MainColor6", Color("#df8d91"))
	animatedSprite.material.set_shader_param("R_MainColor1", Color("#5c5c5c"))
	animatedSprite.material.set_shader_param("R_MainColor2", Color("#484848"))
	animatedSprite.material.set_shader_param("R_MainColor3", Color("#343434"))
#	animatedSprite.material.set_shader_param("R_MainColor4", Color("#D73252"))
#	animatedSprite.material.set_shader_param("R_MainColor5", Color("#78201e"))
#	animatedSprite.material.set_shader_param("R_MainColor6", Color("#df8d91"))

	animatedSprite.material.set_shader_param("CrystalColor2", Color("#63e763"))
	animatedSprite.material.set_shader_param("R_CrystalColor2", Color("#63e763"))

	icarus.MainColor1 = Color("#5c5c5c")
	icarus.MainColor2 = Color("#484848")
	icarus.MainColor3 = Color("#343434")
	icarus.MainColor4 = Color("#D73252")
	icarus.MainColor5 = Color("#78201e")
	icarus.MainColor6 = Color("#df8d91")

	hermes.MainColor1 = Color("#5c5c5c")
	hermes.MainColor2 = Color("#484848")
	hermes.MainColor3 = Color("#343434")
	hermes.MainColor4 = Color("#D73252")
	hermes.MainColor5 = Color("#78201e")
	hermes.MainColor6 = Color("#df8d91")

func x_x8_weaponget():
	get_node("animatedSprite").frames = x_x8_sprites
	get_node("Shot").normal_sprites = x_x8_sprites
	get_node("Shot").arm_pointing_sprites = x_x8_sprites_arm
	if CharacterManager.infinite_x_activated:
		get_node("animatedSprite").get_node("head_armor").self_modulate = Color(1, 1, 1, 0)
		get_node("animatedSprite").get_node("body_armor").self_modulate = Color(1, 1, 1, 0)
		get_node("animatedSprite").get_node("arms_armor").self_modulate = Color(1, 1, 1, 0)
		get_node("animatedSprite").get_node("cannon_armor").self_modulate = Color(1, 1, 1, 0)
		get_node("animatedSprite").get_node("legs_armor").self_modulate = Color(1, 1, 1, 0)

func infinite_x_weaponget():
	get_node("animatedSprite").frames = infinite_x_sprites
	get_node("animatedSprite").get_node("head_armor").self_modulate = Color(1, 1, 1, 0)
	get_node("animatedSprite").get_node("body_armor").self_modulate = Color(1, 1, 1, 0)
	get_node("animatedSprite").get_node("arms_armor").self_modulate = Color(1, 1, 1, 0)
	get_node("animatedSprite").get_node("cannon_armor").self_modulate = Color(1, 1, 1, 0)
	get_node("animatedSprite").get_node("legs_armor").self_modulate = Color(1, 1, 1, 0)
	get_node("animatedSprite").get_node("ultimate_armor").frames = infinite_x_sprites
	get_node("animatedSprite").get_node("ultimate_canon").frames = infinite_x_sprites_arm
	get_node("Shot").normal_sprites = infinite_x_sprites
	get_node("Shot").arm_pointing_sprites = infinite_x_sprites_arm

func _process(delta: float) -> void :
	._process(delta)

func has_just_pressed_left() -> bool:
	return get_action_just_pressed("left_emulated")

func has_just_pressed_right() -> bool:
	return get_action_just_pressed("right_emulated")

func check_for_dash():
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

func equip_hermes_head_parts():
	get_node("Charge").charge_time_reduction = 0.45
	get_node("JumpDamage").deactivate()

func equip_hermes_body_parts():
	var dmg = get_node("Damage")
	dmg.active = false
	dmg.damage_reduction = 33
	dmg.prevent_knockbacks = false
	dmg.conflicting_moves = ["Death", "WallSlide", "Ride"]
	get_node("LifeSteal").activate()

func equip_hermes_arms_parts():
	var cannon = get_node("Shot")
	var hermes_Buster = cannon.get_node("Hermes Buster")
	var icarus_Buster = cannon.get_node("Icarus Buster")
	var altfire = get_node("AltFire")
	
	hermes_Buster.active = true
	icarus_Buster.active = false
	cannon.upgraded = true
	cannon.infinite_charged_ammo = false
	cannon.infinite_regular_ammo = true
	cannon.update_list_of_weapons()
	cannon.set_current_weapon(hermes_Buster)
	altfire.switch_to_hermes()

func equip_hermes_legs_parts():
	var dash = get_node("Dash")
	var airdash = get_node("AirDash")
	var airjump = get_node("AirJump")
	var fall = get_node("Fall")
	dash.upgraded = true
	dash.invulnerability_duration = 0.475
	airjump.set_max_air_jumps(0)
	airdash.upgraded = true
	airdash.max_airdashes = 1
	airdash.airdash_count = 2
	airdash.invulnerability_duration = 0.475
	get_node("Jump").max_jump_time = 0.625
	get_node("Jump").jump_velocity = 320
	get_node("DashJump").max_jump_time = 0.625
	get_node("DashJump").jump_velocity = 320
	get_node("WallJump").max_jump_time = 0.625
	get_node("WallJump").jump_velocity = 320
	get_node("DashWallJump").max_jump_time = 0.625
	get_node("DashWallJump").jump_velocity = 320
	
	get_node("Walk").horizontal_velocity = 90
	get_node("Jump").horizontal_velocity = 90
	get_node("Jump").dash_momentum = 210
	get_node("DashJump").horizontal_velocity = 210
	get_node("WallJump").horizontal_velocity = 90
	get_node("DashWallJump").horizontal_velocity = 210
	airjump.horizontal_velocity = 90
	airjump.normal_momentum = 90
	airjump.dash_momentum = 210
	dash.horizontal_velocity = 210
	airdash.horizontal_velocity = 210
	fall.horizontal_velocity = 90
	fall.dash_momentum = 210

func equip_icarus_head_parts():
	get_node("Charge").charge_time_reduction = 0
	get_node("JumpDamage").activate()

func equip_icarus_body_parts():
	var dmg = get_node("Damage")
	dmg.active = false
	dmg.damage_reduction = 50
	dmg.prevent_knockbacks = true
	dmg.conflicting_moves = ["Death", "Nothing"]
	get_node("LifeSteal").deactivate()

func equip_icarus_arms_parts():
	var cannon = get_node("Shot")
	var icarus_Buster = cannon.get_node("Icarus Buster")
	var hermes_Buster = cannon.get_node("Hermes Buster")
	var altfire = get_node("AltFire")
	icarus_Buster.active = true
	hermes_Buster.active = false
	cannon.upgraded = true
	cannon.infinite_charged_ammo = true
	cannon.infinite_regular_ammo = false
	cannon.update_list_of_weapons()
	cannon.set_current_weapon(icarus_Buster)
	altfire.switch_to_icarus()

func equip_icarus_legs_parts():
	var dash = get_node("Dash")
	var airdash = get_node("AirDash")
	var airjump = get_node("AirJump")
	var fall = get_node("Fall")
	dash.upgraded = false
	dash.dash_duration = 0.55
	dash.invulnerability_duration = 0
	airdash.upgraded = false
	airdash.max_airdashes = 2
	airdash.invulnerability_duration = 0
	airjump.set_max_air_jumps(1)
	
	get_node("Jump").max_jump_time = 0.625
	get_node("Jump").jump_velocity = 320
	get_node("DashJump").max_jump_time = 0.625
	get_node("DashJump").jump_velocity = 320
	get_node("WallJump").max_jump_time = 0.625
	get_node("WallJump").jump_velocity = 320
	get_node("DashWallJump").max_jump_time = 0.625
	get_node("DashWallJump").jump_velocity = 320
	airjump.jump_velocity = 140
	
	get_node("Walk").horizontal_velocity = 90
	get_node("Jump").horizontal_velocity = 90
	get_node("Jump").dash_momentum = 210
	get_node("DashJump").horizontal_velocity = 210
	get_node("WallJump").horizontal_velocity = 90
	get_node("DashWallJump").horizontal_velocity = 210
	airjump.horizontal_velocity = 90
	airjump.normal_momentum = 90
	airjump.dash_momentum = 210
	dash.horizontal_velocity = 210
	airdash.horizontal_velocity = 210
	fall.horizontal_velocity = 90
	fall.dash_momentum = 210

func equip_ultima_head_parts():
	pass

func equip_ultima_body_parts():
	pass

func equip_ultima_arms_parts():
	pass

func equip_ultima_legs_parts():
	pass

func equip_parts(collectible: String):
	if CharacterManager.ultimate_buster:
		using_upgrades = true
	
	if is_armor_part(collectible):
		add_part_to_current_armor(collectible)
		call("equip_" + collectible + "_parts")
		get_node("Armor").display(collectible)
		emit_signal("equipped_armor")
		using_upgrades = true
		
	elif is_heart(collectible):
		equip_heart()
		using_upgrades = true
		
	elif is_subtank(collectible):
		equip_subtank(collectible)
		using_upgrades = true
		
	elif is_weapon(collectible):
		equip_weapon(collectible)


