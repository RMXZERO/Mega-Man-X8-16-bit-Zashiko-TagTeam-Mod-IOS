extends Character
class_name Axl

export  var skip_intro: bool = false

onready var _sprites_pistol_A: Resource = preload("res://Axl_mod/Player/Sprites/axl.tres")
onready var _sprites_pistol_B: Resource = preload("res://Axl_mod/Player/Sprites/axl_pistol.tres")

onready var _sprites_raygun: Resource = preload("res://Axl_mod/Player/Sprites/ray_gun/ray_gun.tres")

onready var _sprites_sprialmagnum_A: Resource = preload("res://Axl_mod/Player/Sprites/spiral_magnum/spiral_magnum.tres")
onready var _sprites_spiralmagnum_B: Resource = preload("res://Axl_mod/Player/Sprites/spiral_magnum/spiral_magnum_B.tres")

onready var _sprites_blackarrow: Resource = preload("res://Axl_mod/Player/Sprites/black_arrow/black_arrow.tres")

onready var _sprites_plasmagun: Resource = preload("res://Axl_mod/Player/Sprites/plasma_gun/plasma_gun.tres")

onready var _sprites_blastlauncher_A: Resource = preload("res://Axl_mod/Player/Sprites/blast_launcher/blast_launcher_A.tres")
onready var _sprites_blastlauncher_B: Resource = preload("res://Axl_mod/Player/Sprites/blast_launcher/blast_launcher_B.tres")

onready var _sprites_boundblaster_A: Resource = preload("res://Axl_mod/Player/Sprites/bound_blaster/bound_blaster.tres")
onready var _sprites_boundblaster_B: Resource = preload("res://Axl_mod/Player/Sprites/bound_blaster/bound_blaster_B.tres")

onready var _sprites_icegattling_1: Resource = preload("res://Axl_mod/Player/Sprites/ice_gattling/ice_gattling_1.tres")
onready var _sprites_icegattling_2: Resource = preload("res://Axl_mod/Player/Sprites/ice_gattling/ice_gattling_2.tres")
onready var _sprites_icegattling_3: Resource = preload("res://Axl_mod/Player/Sprites/ice_gattling/ice_gattling_3.tres")
onready var _sprites_icegattling_4: Resource = preload("res://Axl_mod/Player/Sprites/ice_gattling/ice_gattling_4.tres")

onready var _sprites_flameburner: Resource = preload("res://Axl_mod/Player/Sprites/flame_burner/flame_burner.tres")
onready var lowjumpcast: Label = $lowjumpcast

var current_armor: Array = ["no_head", "no_body", "no_arms", "no_legs"]
var armor_sprites: Array = []
var flash_timer: float = 0.0
var block_charging: bool = false
var dashfall: bool = false
var dashjumps_since_jump: int = 0
var raycast_down: RayCast2D
var colliding: bool = true
var using_upgrades: bool = false
var grabbed: bool = false
var holding_down: bool = false
var ride_eject_delay: float = 0.0
var ride: Node2D

signal walljump
signal wallslide
signal dashjump
signal airdash
signal firedash
signal collected_health(amount)
signal weapon_stasis
signal end_weapon_stasis
signal dry_dash
signal received_damage(character)
signal equipped_armor
signal at_max_hp


func deactivate() -> void :
	stop_listening_to_inputs()
	stop_charge()
	stop_shot()

func activate() -> void :
	if is_colliding():
		reactivate_charge()
		.activate()
	return

func has_control() -> bool:
	if grabbed:
		return true
	if listening_to_inputs:
		return true
	elif ride:
		return ride.listening_to_inputs
	return false

func is_riding() -> bool:
	return is_instance_valid(ride)

func on_land() -> void :
	dashjumps_since_jump = 0
	dashfall = false

func dashjump_signal() -> void :
	emit_signal("dashjump")
	dashjumps_since_jump += 1

func airdash_signal() -> void :
	emit_signal("airdash")

func firedash_signal() -> void :
	emit_signal("firedash")

func stop_charge() -> void :
	for ability in executing_moves:
		if ability.name == "Charge":
			ability.EndAbility()
	block_charging = true

func update_facing_direction() -> void :
	if direction.x < 0:
		facing_right = false;
		Event.emit_signal("player_faced_left")
	elif direction.x > 0:
		facing_right = true;
		Event.emit_signal("player_faced_right")
	if animatedSprite.scale.x != get_facing_direction():
		animatedSprite.scale.x = get_facing_direction()

func reactivate_charge() -> void :
	block_charging = false

func reduce_hitbox() -> void :
	collisor.disabled = true

func increase_hitbox() -> void :
	collisor.disabled = false

func _ready() -> void :
	current_armor = ["no_head", "no_body", "no_arms", "no_legs"]
	Event.listen("collected", self, "equip_parts")
	Event.listen("collected", self, "collect")
	listen("land", self, "on_land")
	equip_axl_parts()
	call("equip_parts", "collectible")
	save_original_colors()
	CharacterManager.weaponget = false
	if is_current_player:
		GameManager.set_player(self)
		Event.call_deferred("emit_signal", "player_set")
	if not "axl_giga_crash" in GameManager.collectibles:
		GameManager.add_collectible_to_savedata("axl_giga_crash")

func get_armor_sprites() -> Array:
	var sprites = []
	for child in animatedSprite.get_children():
		if "armor" in child.name:
			sprites.append(child)
	return sprites

func _process(delta: float) -> void :
	if get_action_pressed("move_down"):
		holding_down = true
	else:
		holding_down = false
	if get_action_pressed("fire") or get_action_pressed("alt_fire"):
		is_shooting = true
	else:
		is_shooting = false
		var _shot_node = get_node("Shot")
		if _shot_node != null:
			if _shot_node.current_weapon != null:
				if _shot_node.current_weapon.name == "IceGattling":
					_shot_node.current_weapon._gattling_sprites = 1
					if animatedSprite.frames != _sprites_icegattling_1:
						animatedSprite.frames = _sprites_icegattling_1
	if ride_eject_delay >= 0:
		ride_eject_delay -= delta
	process_flash(delta)

func process_flash(delta: float) -> void :
	if flash_timer > 0:
		flash_timer += delta
		if flash_timer > 0.034:
			end_flash()

func equip_axl_parts() -> void :
	get_node("JumpDamage").deactivate()
	var lifesteal = get_node("LifeSteal")
	lifesteal.activate()
	lifesteal.first_decay = 0.5
	lifesteal.lifesteal_decay = 0.5
	lifesteal.minimum_time_between_heals = 0.2
	var dmg = get_node("Damage")
	dmg.damage_reduction = 0
	dmg.prevent_knockbacks = false
	dmg.conflicting_moves = ["Death", "WallSlide", "Ride"]

	var shot = get_node("Shot")
	shot.update_list_of_weapons()
	shot.ammo_cost_reduction = 1
	var normal_pistol = shot.get_node("Pistol")
	shot.set_current_weapon(normal_pistol)
	var dash = get_node("Dash")
	dash.dash_duration = 0.55
	dash.horizontal_velocity = 260
	var airdash = get_node("AirDash")
	airdash.upgraded = true
	airdash.dash_duration = 0.55
	airdash.horizontal_velocity = 260
	airdash.max_airdashes = 2
	airdash.airdash_count = 2
	var hover = get_node("Hover")
	hover.upgraded = false
	hover.horizontal_velocity = 90
	hover.vertical_velocity = 30
	get_node("DashWallJump").horizontal_velocity = 260
	get_node("DashJump").horizontal_velocity = 260
	get_node("Fall").dash_momentum = 260
	var _afterimagen = animatedSprite.get_node("afterImagesn")
	_afterimagen.upgraded = true

	var player_shot_node: = get_node("Shot")
	var player_altshot_node: = get_node("AltFire")
	var player_giga_crash: = get_node("Special").get_node("GigaCrash")
	var desperation: = get_node("Desperation")
	var dmg_multiplikator = 1.0
	var shot_delay = 1.0
	var bullet_speed = 1.0

	desperation.desperation_reduce_ammo = 1.0
	desperation.desperation_damage = 3
	player_giga_crash.recover_ammo = false
	player_giga_crash.recover_speed = 0
	
	for shots in player_shot_node.get_children():
		if shots is WeaponAxl:
			shots.extra_damage = dmg_multiplikator
			shots.extra_delay = shot_delay
			shots.extra_speed = bullet_speed
	for shots in player_altshot_node.get_children():
		if shots is WeaponAxl:
			shots.extra_damage = dmg_multiplikator
			shots.extra_delay = shot_delay
			shots.extra_speed = bullet_speed

func equip_axl_white_parts() -> void :
	get_node("JumpDamage").deactivate()
	var lifesteal = get_node("LifeSteal")
	lifesteal.activate()
	lifesteal.first_decay = 1.5
	lifesteal.lifesteal_decay = 0.65
	lifesteal.minimum_time_between_heals = 0.1
	var dmg = get_node("Damage")
	dmg.damage_reduction = 30
	dmg.prevent_knockbacks = true
	dmg.conflicting_moves = ["Death", "Nothing"]

	var shot = get_node("Shot")
	shot.update_list_of_weapons()
	shot.ammo_cost_reduction = 0.5
	var normal_pistol = shot.get_node("Pistol")
	shot.set_current_weapon(normal_pistol)
	var _transform = shot.get_node("Transform")
	_transform.ammo_per_shot = 0
	var dash = get_node("Dash")
	dash.dash_duration = 0.44
	dash.horizontal_velocity = 300
	var airdash = get_node("AirDash")
	airdash.upgraded = true
	airdash.dash_duration = 0.44
	airdash.horizontal_velocity = 300
	airdash.max_airdashes = 4
	airdash.airdash_count = 4
	var hover = get_node("Hover")
	hover.upgraded = true
	hover.horizontal_velocity = 115
	hover.vertical_velocity = 90
	get_node("DashWallJump").horizontal_velocity = 300
	get_node("DashJump").horizontal_velocity = 300
	get_node("Fall").dash_momentum = 300
	var _afterimagen = animatedSprite.get_node("afterImagesn")
	_afterimagen.upgraded = true

	var player_shot_node: = get_node("Shot")
	var player_altshot_node: = get_node("AltFire")
	var player_giga_crash: = get_node("Special").get_node("GigaCrash")
	var desperation: = get_node("Desperation")
	var dmg_multiplikator = 1.2
	var shot_delay = 0.8
	var bullet_speed = 1.2

	desperation.desperation_reduce_ammo = 0.75
	desperation.desperation_damage = 4
	player_giga_crash.recover_ammo = false
	player_giga_crash.recover_speed = 0
	
	for shots in player_shot_node.get_children():
		if shots is WeaponAxl:
			shots.extra_damage = dmg_multiplikator
			shots.extra_delay = shot_delay
			shots.extra_speed = bullet_speed
	for shots in player_altshot_node.get_children():
		if shots is WeaponAxl:
			shots.extra_damage = dmg_multiplikator
			shots.extra_delay = shot_delay
			shots.extra_speed = bullet_speed

func equip_cheat_axl_parts() -> void :
	spike_invincibility = true
	var player_shot_node: = get_node("Shot")
	var player_altshot_node: = get_node("AltFire")
	var player_giga_crash: = get_node("Special").get_node("GigaCrash")
	var desperation: = get_node("Desperation")
	var dmg_multiplikator = 2.0
	var shot_delay = 0.5
	var bullet_speed = 1.5
	
	desperation.desperation_reduce_ammo = 0.5
	desperation.desperation_damage = 6
	player_giga_crash.recover_ammo = true
	player_giga_crash.recover_speed = 10
	
	for shots in player_shot_node.get_children():
		if shots is WeaponAxl:
			shots.extra_damage = dmg_multiplikator
			shots.extra_delay = shot_delay
			shots.extra_speed = bullet_speed
			shots.ammo_per_shot = 0
			shots.max_shots_alive = 99
	for shots in player_altshot_node.get_children():
		if shots is WeaponAxl:
			shots.extra_damage = dmg_multiplikator
			shots.extra_delay = shot_delay
			shots.extra_speed = bullet_speed
			shots.ammo_per_shot = 0
			shots.max_shots_alive = 99
	
	var lifesteal = get_node("LifeSteal")
	lifesteal.activate()
	lifesteal.first_decay = 10.0
	lifesteal.lifesteal_decay = 5.0
	lifesteal.minimum_time_between_heals = 0.1
	
	var dmg = get_node("Damage")
	dmg.damage_reduction = 80
	dmg.prevent_knockbacks = true
	dmg.conflicting_moves = ["Death", "Nothing"]
	var _afterimagen = animatedSprite.get_node("afterImagesn")
	_afterimagen.upgraded = true

	var shot = get_node("Shot")
	shot.update_list_of_weapons()
	shot.ammo_cost_reduction = 0.5
	var normal_pistol = shot.get_node("Pistol")
	shot.set_current_weapon(normal_pistol)
	var _transform = shot.get_node("Transform")
	_transform.ammo_per_shot = 0
	var dash = get_node("Dash")
	dash.dash_duration = 0.44
	dash.horizontal_velocity = 400
	var airdash = get_node("AirDash")
	airdash.upgraded = true
	airdash.dash_duration = 0.44
	airdash.horizontal_velocity = 400
	airdash.max_airdashes = 4
	airdash.airdash_count = 4
	var hover = get_node("Hover")
	hover.upgraded = true
	hover.horizontal_velocity = 150
	hover.vertical_velocity = 120
	get_node("DashWallJump").horizontal_velocity = 400
	get_node("DashJump").horizontal_velocity = 400
	get_node("Fall").dash_momentum = 400

func is_full_armor() -> String:
	return "axl"

func equip_parts(collectible: String) -> void :
	CharacterManager.set_axl_colors(animatedSprite)
	equip_axl_parts()
	emit_signal("equipped_armor")
	
	if CharacterManager.white_axl_armor:
		equip_axl_white_parts()
		using_upgrades = true
		
	if CharacterManager.cheat_axl_activated:
		equip_cheat_axl_parts()
		using_upgrades = true
	
	if CharacterManager.ultimate_buster:
		using_upgrades = true
		
	if CharacterManager.player_desperation:
		get_node("Desperation").active = true
		using_upgrades = true
		
	if CharacterManager.axl_saber_combo:
		get_node("SaberCombo").active = true
		
	if is_heart(collectible):
		equip_heart()
		using_upgrades = true
		
	elif is_subtank(collectible):
		equip_subtank(collectible)
		using_upgrades = true
		
	elif is_weapon(collectible):
		equip_weapon(collectible)

func is_weapon(collectible: String) -> bool:
	return "weapon" in collectible

func equip_weapon(collectible: String) -> void :
	get_node("Shot").unlock_weapon(collectible)

func get_current_weapon():
	return get_node("Shot").current_weapon

func is_heart(collectible: String) -> bool:
	return "heart" in collectible or "life" in collectible

func is_subtank(collectible: String) -> bool:
	return "tank" in collectible

func equip_heart() -> void :
	var i = GameManager.team.find(self)
	if i == -1:
		return
	var buff = CharacterManager.heart_tank_buff_amt
	GameManager.team[i].max_health += buff
	GameManager.team[i].recover_health(buff)
	num_equipped_hearts += 1

func recover_health(value: float) -> void :
	if current_health < max_health:
		current_health += value
	if current_health >= max_health:
		emit_signal("at_max_hp")

func equip_subtank(collectible: String) -> void :
	for subtank in $Subtanks.get_children():
		if subtank.subtank.id == collectible:
			subtank.activate()

func get_subtank_current_health(id):
	for subtank in $Subtanks.get_children():
		if subtank.get_id() == id:
			return subtank.current_health
	return - 1

func add_part_to_current_armor(collectible: String) -> void :
	var part_location = collectible.replace("icarus_", "").replace("hermes_", "")
	for location in current_armor:
		if part_location in location:
			current_armor.remove(current_armor.find(location))
			current_armor.append(collectible)
	GameManager.remove_equip_exception(part_location)

func is_armor_part(collectible: String) -> bool:
	return "icarus" in collectible or "hermes" in collectible

func finished_equipping() -> void :
	get_node("Shot").update_list_of_weapons()

func has_any_upgrades() -> bool:
	return true

func collect(collectible: String) -> void :
	GameManager.add_collectible_to_savedata(collectible)

func save_original_colors() -> void :
	colors.append(animatedSprite.material.get_shader_param("AxlMainColor1"))
	colors.append(animatedSprite.material.get_shader_param("AxlMainColor2"))
	colors.append(animatedSprite.material.get_shader_param("AxlMainColor3"))
	colors.append(animatedSprite.material.get_shader_param("AxlMainColor4"))
	colors.append(animatedSprite.material.get_shader_param("AxlMainColor5"))
	colors.append(animatedSprite.material.get_shader_param("AxlMainColor6"))
	colors.append(animatedSprite.material.get_shader_param("AxlCrystalColor1"))
	colors.append(animatedSprite.material.get_shader_param("AxlCrystalColor2"))
	colors.append(animatedSprite.material.get_shader_param("AxlCrystalColor3"))
	colors.append(animatedSprite.material.get_shader_param("AxlHairColor1"))
	colors.append(animatedSprite.material.get_shader_param("AxlHairColor2"))
	colors.append(animatedSprite.material.get_shader_param("AxlHairColor3"))
	colors.append(animatedSprite.material.get_shader_param("AxlYellowColor1"))
	colors.append(animatedSprite.material.get_shader_param("AxlYellowColor2"))
	colors.append(animatedSprite.material.get_shader_param("AxlRedColor1"))
	colors.append(animatedSprite.material.get_shader_param("AxlRedColor2"))
	colors.append(animatedSprite.material.get_shader_param("AxlFlameColor1"))
	colors.append(animatedSprite.material.get_shader_param("AxlFlameColor2"))
	colors.append(animatedSprite.material.get_shader_param("AxlFlameColor3"))

func change_palette(new_colors: Color, paint_armor: bool = true) -> void :
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	set_new_colors_on_shader_parameters(animatedSprite, new_colors)
	if paint_armor:
		for sprite in armor_sprites:
			set_new_colors_for_armor_on_shader_parameters(sprite, new_colors)
	else:
		for sprite in armor_sprites:
			set_new_colors_for_armor_on_shader_parameters(sprite, $Armor.BodyColors)

func set_new_colors_on_shader_parameters(object, new_colors) -> void :
	object.material.set_shader_param("R_AxlMainColor1", new_colors[0])
	object.material.set_shader_param("R_AxlMainColor2", new_colors[1])
	object.material.set_shader_param("R_AxlMainColor3", new_colors[2])
	object.material.set_shader_param("R_AxlMainColor4", new_colors[3])
	object.material.set_shader_param("R_AxlMainColor5", new_colors[4])
	object.material.set_shader_param("R_AxlMainColor6", new_colors[5])
	
func set_new_colors_for_armor_on_shader_parameters(object, new_colors) -> void :
	object.material.set_shader_param("R_AxlMainColor2", new_colors[1])
	object.material.set_shader_param("R_AxlMainColor3", new_colors[2])

func disable_collision() -> void :
	colliding = false
	get_node("CollisionShape2D").set_deferred("disabled", true)
	
func enable_collision() -> void :
	colliding = true
	get_node("CollisionShape2D").set_deferred("disabled", false)

func is_colliding() -> bool:
	return colliding

func flash() -> void :
	if has_health():
		animatedSprite.material.set_shader_param("Flash", 1)
		flash_timer = 0.01

func end_flash() -> void :
	animatedSprite.material.set_shader_param("Flash", 0)
	flash_timer = 0

func are_low_walljump_raycasts_active() -> bool:
	var b: = true
	for raycast in low_jumpcasts:
		if not raycast.enabled:
			b = false
	return b

func activate_low_walljump_raycasts() -> void :
	for raycast in low_jumpcasts:
		raycast.enabled = true
	lowjumpcast.text = "on"

func deactivate_low_walljump_raycasts() -> void :
	for raycast in low_jumpcasts:
		raycast.enabled = false
	lowjumpcast.text = "off"

func set_global_position(new_position: Vector2) -> void :
	global_position = new_position

func start_dashfall() -> void :
	if not is_on_floor():
		dashfall = true

func set_x(pos) -> void :
	if can_be_moved():
		global_position.x = pos
func set_y(pos) -> void :
	if can_be_moved():
		global_position.y = pos

func move_x(difference) -> void :
	if can_be_moved():
		global_position.x += difference
func move_y(difference) -> void :
	if can_be_moved():
		global_position.y += difference

func can_be_moved() -> bool:
	return not is_executing("Ride")

func stop_forced_movement(forcer = null) -> void :
	if not is_executing("Ride"):
		emit_signal("stop_forced_movement", forcer)
		grabbed = false
