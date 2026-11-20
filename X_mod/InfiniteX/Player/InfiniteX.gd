extends Character
class_name InfiniteX

export  var skip_intro: bool = false

onready var lowjumpcast: Label = $lowjumpcast

onready var infinite_x_sprites: Resource = preload("res://X_mod/InfiniteX/Sprites/InfiniteX.tres")
onready var infinite_x_sprites_arm: Resource = preload("res://X_mod/InfiniteX/Sprites/InfiniteX_leftarm.tres")
onready var x_x8_sprites: Resource = preload("res://X_mod/X8/Sprites/X_X8.tres")
onready var x_x8_sprites_arm: Resource = preload("res://X_mod/X8/Sprites/X_X8_leftarm.tres")

onready var base_shot: = get_node("Shot")
onready var icarus: = base_shot.get_node("Icarus Buster")
onready var hermes: = base_shot.get_node("Hermes Buster")
onready var alt_icarus: = get_node("AltFire").get_node("Icarus Buster")
onready var alt_hermes: = get_node("AltFire").get_node("Buster")
onready var opticshield: = base_shot.get_node("OpticShield")
onready var squeezebomb: = base_shot.get_node("SqueezeBomb")
onready var darkarrow: = base_shot.get_node("DarkArrow")
onready var thunderdancer: = base_shot.get_node("ThunderDancer")
onready var blastlauncher: = base_shot.get_node("BlastLauncher")
onready var crystalbouncer: = base_shot.get_node("CrystalBouncer")
onready var driftdiamond: = base_shot.get_node("DriftDiamond")
onready var firedash: = base_shot.get_node("FireDash")
var recover_ammo: bool = false

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


func deactivate():
	stop_listening_to_inputs()
	stop_charge()
	stop_shot()
	
func activate():
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

func stop_charge():
	for ability in executing_moves:
		if ability.name == "Charge":
			ability.EndAbility()
	block_charging = true

func update_facing_direction():
	if direction.x < 0:
		facing_right = false;
		Event.emit_signal("player_faced_left")
	elif direction.x > 0:
		facing_right = true;
		Event.emit_signal("player_faced_right")
	if animatedSprite.scale.x != get_facing_direction():
		animatedSprite.scale.x = get_facing_direction()

func reactivate_charge():
	block_charging = false

func reduce_hitbox():
	collisor.disabled = true

func increase_hitbox():
	collisor.disabled = false

func _ready() -> void :
	current_armor = ["no_head", "no_body", "no_arms", "no_legs"]
	Event.listen("collected", self, "equip_parts")
	Event.listen("collected", self, "collect")
	listen("land", self, "on_land")
	save_original_colors()
	set_sprite()
	call("equip_parts", "collectible")
	armor_sprites = get_armor_sprites()
	CharacterManager.weaponget = false
	if is_current_player:
		GameManager.set_player(self)
		Event.call_deferred("emit_signal", "player_set")
	if not "desperation_nova_strike" in GameManager.collectibles:
		GameManager.add_collectible_to_savedata("desperation_nova_strike")

func set_sprite():
	if CharacterManager.use_old_sprite:
		get_node("animatedSprite").frames = infinite_x_sprites
		get_node("Shot").normal_sprites = infinite_x_sprites
		get_node("Shot").arm_pointing_sprites = infinite_x_sprites_arm
		get_node("AltFire").normal_sprites = infinite_x_sprites
		get_node("AltFire").arm_pointing_sprites = infinite_x_sprites_arm
	else:
		get_node("animatedSprite").frames = x_x8_sprites
		get_node("Shot").normal_sprites = x_x8_sprites
		get_node("Shot").arm_pointing_sprites = x_x8_sprites_arm
		get_node("AltFire").normal_sprites = x_x8_sprites
		get_node("AltFire").arm_pointing_sprites = x_x8_sprites_arm

func get_armor_sprites() -> Array:
	var sprites = []
	for child in animatedSprite.get_children():
		if "armor" in child.name:
			sprites.append(child)
	return sprites

func _process(delta: float) -> void :
	if ride_eject_delay >= 0:
		ride_eject_delay -= delta
	process_flash(delta)
	ammo_recover(delta)

func process_flash(delta):
	if flash_timer > 0:
		flash_timer += delta
		if flash_timer > 0.034:
			end_flash()

func ammo_recover(delta):
	base_shot.Update_Giga_Crash()
	if not opticshield.has_max_ammo():
		opticshield.current_ammo = clamp(opticshield.current_ammo + delta * 4, 0, opticshield.max_ammo)
	if not squeezebomb.has_max_ammo():
		squeezebomb.current_ammo = clamp(squeezebomb.current_ammo + delta * 4, 0, squeezebomb.max_ammo)
	if not darkarrow.has_max_ammo():
		darkarrow.current_ammo = clamp(darkarrow.current_ammo + delta * 4, 0, darkarrow.max_ammo)
	if not thunderdancer.has_max_ammo():
		thunderdancer.current_ammo = clamp(thunderdancer.current_ammo + delta * 4, 0, thunderdancer.max_ammo)
	if not blastlauncher.has_max_ammo():
		blastlauncher.current_ammo = clamp(blastlauncher.current_ammo + delta * 4, 0, blastlauncher.max_ammo)
	if not crystalbouncer.has_max_ammo():
		crystalbouncer.current_ammo = clamp(crystalbouncer.current_ammo + delta * 4, 0, crystalbouncer.max_ammo)
	if not driftdiamond.has_max_ammo():
		if not CharacterManager.xdrive:
			driftdiamond.current_ammo = clamp(driftdiamond.current_ammo + delta * 4, 0, driftdiamond.max_ammo)
			$XDrive.remove_buff()
	if not firedash.has_max_ammo():
		firedash.current_ammo = clamp(firedash.current_ammo + delta * 4, 0, firedash.max_ammo)
	if CharacterManager.xdrive:
		driftdiamond.current_ammo = clamp(driftdiamond.current_ammo - delta * 2, 0, driftdiamond.max_ammo)
		if not driftdiamond.has_ammo():
			$XDrive.remove_buff()

func equip_infinite_head_parts():
	get_node("Charge").charge_time_reduction = 0.70
	get_node("JumpDamage").activate()

func equip_infinite_body_parts():
	spike_invincibility = true
	var dmg = get_node("Damage")
	dmg.damage_reduction = 80
	dmg.prevent_knockbacks = true
	dmg.conflicting_moves = ["Death", "Nothing"]
	var lifesteal = get_node("LifeSteal")
	lifesteal.activate()
	lifesteal.first_decay = 999999.0
	lifesteal.lifesteal_decay = 999999.0
	lifesteal.minimum_time_between_heals = 0.1

func equip_infinite_arms_parts():
	var cannon = get_node("Shot")
	var icarus_Buster = cannon.get_node("Icarus Buster")
	var hermes_Buster = cannon.get_node("Hermes Buster")
	var altfire = get_node("AltFire")
	icarus_Buster.active = false
	hermes_Buster.active = true
	cannon.upgraded = true
	cannon.infinite_charged_ammo = true
	cannon.infinite_regular_ammo = true
	cannon.update_list_of_weapons()
	cannon.set_current_weapon(hermes_Buster)
	altfire.switch_to_icarus()
	
	get_node("Desperation").desperation_reduce_ammo = 1.5
	get_node("Desperation").desperation_damage = 16
	get_node("Hadoken").hadoken_damage = 512
	get_node("Shoryuuken").shoryuuken_damage = 512
	get_node("FalconGiga").falcon_giga_damage = 32
	get_node("BladeGiga").blade_giga_damage = 64
	get_node("NinjaGiga").ninja_giga_damage = 48
	get_node("GigaCrash").giga_crash_damage = 128
	get_node("NovaStrike").nova_strike_damage = 256
	get_node("SaberCombo").saber_damage = 24
	cannon.get_node("CrystalBouncer").sould_body_damage = 5
	cannon.get_node("DriftDiamond").frost_tower_damage = 10
	cannon.get_node("BlastLauncher").double_cyclone_damage = 10
	cannon.get_node("OpticShield").ray_gun_damage = 15
	cannon.get_node("SqueezeBomb").squeeze_bomb_damage = 5


func equip_infinite_legs_parts():
	get_node("Hover").hover_damage = 0.5
	var dash = get_node("Dash")
	var airdash = get_node("AirDash")
	var airjump = get_node("AirJump")
	var fall = get_node("Fall")
	dash.upgraded = true
	dash.dash_duration = 0.55
	dash.invulnerability_duration = 0.475
	airdash.upgraded = true
	airdash.dash_duration = 0.55
	airdash.invulnerability_duration = 0.475
	airdash.max_airdashes = 4
	airdash.airdash_count = 4
	
	#dash.get_node("particles2D").texture = load("res://src/Effects/Textures/follow_shot_ultimate.png")
	#airdash.get_node("particles2D").texture = load("res://src/Effects/Textures/follow_shot_ultimate.png")
	
	var hover = get_node("Hover")
	hover.upgraded = true
	hover.horizontal_velocity = 220
	hover.vertical_velocity = 220
	
	airjump.set_max_air_jumps(0)
	get_node("Jump").max_jump_time = 0.75
	get_node("Jump").jump_velocity = 420
	get_node("DashJump").max_jump_time = 0.75
	get_node("DashJump").jump_velocity = 420
	get_node("WallJump").max_jump_time = 0.75
	get_node("WallJump").jump_velocity = 420
	get_node("DashWallJump").max_jump_time = 0.75
	get_node("DashWallJump").jump_velocity = 420
	airjump.jump_velocity = 240
	
	get_node("Walk").horizontal_velocity = 120
	get_node("Jump").horizontal_velocity = 120
	get_node("Jump").dash_momentum = 400
	get_node("DashJump").horizontal_velocity = 400
	get_node("WallJump").horizontal_velocity = 120
	get_node("DashWallJump").horizontal_velocity = 400
	get_node("SaberCombo").horizontal_velocity = 120
	get_node("SaberCombo").dash_momentum = 400
	airjump.horizontal_velocity = 120
	airjump.normal_momentum = 120
	airjump.dash_momentum = 400
	dash.horizontal_velocity = 400
	airdash.horizontal_velocity = 400
	fall.horizontal_velocity = 120
	fall.normal_momentum = 120
	fall.dash_momentum = 400

func equip_axl_flameburner_parts() -> void :
	var dmg_multiplikator = 1.5
	var shot_node = get_node("Shot").get_children()
	var alt_shot_node = get_node("AltFire").get_children()
	for buster in shot_node:
		if buster is Weapon or buster is BossWeapon:
			buster.extra_damage = dmg_multiplikator
	for alt_buster in alt_shot_node:
		if alt_buster is Weapon or alt_buster is BossWeapon:
			alt_buster.extra_damage = dmg_multiplikator
	
func equip_cancel_axl_flameburner_parts() -> void :
	var dmg_multiplikator = 1.0
	var shot_node = get_node("Shot").get_children()
	var alt_shot_node = get_node("AltFire").get_children()
	for buster in shot_node:
		if buster is Weapon or buster is BossWeapon:
			buster.extra_damage = dmg_multiplikator
	for alt_buster in alt_shot_node:
		if alt_buster is Weapon or alt_buster is BossWeapon:
			alt_buster.extra_damage = dmg_multiplikator

func is_full_armor() -> String:
	return "infinite"

func equip_parts(collectible: String):
	call("equip_infinite_head_parts")
	call("equip_infinite_body_parts")
	call("equip_infinite_arms_parts")
	call("equip_infinite_legs_parts")
	emit_signal("equipped_armor")
	
	if CharacterManager.player_desperation:
		get_node("Desperation").active = true
		using_upgrades = true
	
	if CharacterManager.ultimate_buster:
		using_upgrades = true
	
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

func recover_health(value: float):
	if current_health < max_health:
		current_health += value
	if current_health >= max_health:
		emit_signal("at_max_hp")

func equip_subtank(collectible: String):
	for subtank in $Subtanks.get_children():
		if subtank.subtank.id == collectible:
			subtank.activate()

func get_subtank_current_health(id) -> int:
	for subtank in $Subtanks.get_children():
		if subtank.get_id() == id:
			return subtank.current_health
	return - 1
	
func add_part_to_current_armor(collectible: String):
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

func collect(collectible: String):
	GameManager.add_collectible_to_savedata(collectible)

func save_original_colors():
	colors.append(animatedSprite.material.get_shader_param("MainColor1"))
	colors.append(animatedSprite.material.get_shader_param("MainColor2"))
	colors.append(animatedSprite.material.get_shader_param("MainColor3"))
	colors.append(animatedSprite.material.get_shader_param("MainColor4"))
	colors.append(animatedSprite.material.get_shader_param("MainColor5"))
	colors.append(animatedSprite.material.get_shader_param("MainColor6"))

func change_palette(new_colors, paint_armor: = true):
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	reset_colors_for_armor_on_shader_parameters(animatedSprite)
	return
	if paint_armor:
		set_new_colors_on_shader_parameters(animatedSprite, new_colors)
	else:
		reset_colors_for_armor_on_shader_parameters(animatedSprite)

func set_new_colors_on_shader_parameters(object, new_colors) -> void :
	object.material.set_shader_param("R_MainColor1", new_colors[0])
	object.material.set_shader_param("R_MainColor2", new_colors[1])
	object.material.set_shader_param("R_MainColor3", new_colors[2])
	object.material.set_shader_param("R_MainColor4", new_colors[3])
	object.material.set_shader_param("R_MainColor5", new_colors[4])
	object.material.set_shader_param("R_MainColor6", new_colors[5])
	
func set_new_colors_for_armor_on_shader_parameters(object, new_colors) -> void :
	object.material.set_shader_param("R_MainColor2", new_colors[1])
	object.material.set_shader_param("R_MainColor3", new_colors[2])

func reset_colors_for_armor_on_shader_parameters(object) -> void :
	object.material.set_shader_param("R_MainColor1", Color("#0080f8"))
	object.material.set_shader_param("R_MainColor2", Color("#0040f0"))
	object.material.set_shader_param("R_MainColor3", Color("#203080"))
	object.material.set_shader_param("R_MainColor4", Color("#78d8f0"))
	object.material.set_shader_param("R_MainColor5", Color("#50a0f0"))
	object.material.set_shader_param("R_MainColor6", Color("#1858b0"))

	object.material.set_shader_param("R_CrystalColor1", Color("#f0f0f0"))
	object.material.set_shader_param("R_CrystalColor2", Color("#f04010"))
	object.material.set_shader_param("R_CrystalColor3", Color("#722237"))

func disable_collision():
	colliding = false
	get_node("CollisionShape2D").set_deferred("disabled", true)
	
func enable_collision():
	colliding = true
	get_node("CollisionShape2D").set_deferred("disabled", false)

func is_colliding() -> bool:
	return colliding

func flash():
	if has_health():
		animatedSprite.material.set_shader_param("Flash", 1)
		flash_timer = 0.01
	
func end_flash():
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

func stop_forced_movement(forcer = null):
	if not is_executing("Ride"):
		emit_signal("stop_forced_movement", forcer)
		grabbed = false
