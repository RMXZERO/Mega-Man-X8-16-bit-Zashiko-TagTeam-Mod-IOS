extends Axl

onready var pallette_sprites_pistol_A: Resource = preload("res://Axl_mod/Player/PalletteSprites/pallette.tres")
onready var pallette_sprites_pistol_B: Resource = preload("res://Axl_mod/Player/PalletteSprites/pallette.tres")

onready var pallette_sprites_raygun: Resource = preload("res://Axl_mod/Player/PalletteSprites/ray_gun/ray_gun.tres")

onready var pallette_sprites_sprialmagnum_A: Resource = preload("res://Axl_mod/Player/PalletteSprites/spiral_magnum/spiral_magnum_A.tres")
onready var pallette_sprites_spiralmagnum_B: Resource = preload("res://Axl_mod/Player/PalletteSprites/spiral_magnum/spiral_magnum_B.tres")

onready var pallette_sprites_blackarrow: Resource = preload("res://Axl_mod/Player/PalletteSprites/black_arrow/black_arrow.tres")

onready var pallette_sprites_plasmagun: Resource = preload("res://Axl_mod/Player/PalletteSprites/plasma_gun/plasma_gun.tres")

onready var pallette_sprites_blastlauncher_A: Resource = preload("res://Axl_mod/Player/PalletteSprites/blast_launcher/blast_launcher_A.tres")
onready var pallette_sprites_blastlauncher_B: Resource = preload("res://Axl_mod/Player/PalletteSprites/blast_launcher/blast_launcher_B.tres")

onready var pallette_sprites_boundblaster_A: Resource = preload("res://Axl_mod/Player/PalletteSprites/bound_blaster/bound_blaster.tres")
onready var pallette_sprites_boundblaster_B: Resource = preload("res://Axl_mod/Player/PalletteSprites/bound_blaster/bound_blaster.tres")

onready var pallette_sprites_icegattling_1: Resource = preload("res://Axl_mod/Player/PalletteSprites/ice_gattling/ice_gattling_1.tres")
onready var pallette_sprites_icegattling_2: Resource = preload("res://Axl_mod/Player/PalletteSprites/ice_gattling/ice_gattling_2.tres")
onready var pallette_sprites_icegattling_3: Resource = preload("res://Axl_mod/Player/PalletteSprites/ice_gattling/ice_gattling_3.tres")
onready var pallette_sprites_icegattling_4: Resource = preload("res://Axl_mod/Player/PalletteSprites/ice_gattling/ice_gattling_4.tres")

onready var pallette_sprites_flameburner: Resource = preload("res://Axl_mod/Player/PalletteSprites/flame_burner/flame_burner.tres")

onready var axl_material: Material = preload("res://Axl_mod/Player/Axl_Material_Shader.tres")
onready var pallette_material: Material = preload("res://Axl_mod/Player/Pallette_Material_Shader.tres")

export var pallette: bool = false
var current_weapon
var less_buggy_pressed_dir: int = 0

func _ready():
	is_current_player = true
	CharacterManager.weaponget = true
	call("equip_axl_parts")
	Input.action_release("dash_emulated")
	Input.action_release("fire_emulated")
	Input.action_release("alt_fire_emulated")
	Input.action_release("up_emulated")
	Input.action_release("left_emulated")
	Input.action_release("right_emulated")
	Input.action_release("down_emulated")
	Input.action_release("jump_emulated")
	is_shooting = false
	Event.emit_signal("is_not_shooting")
	animatedSprite.material = axl_material
	CharacterManager.set_axl_colors(animatedSprite)
	if pallette:
		pallette_weaponget()
		animatedSprite.material = pallette_material
		CharacterManager.set_pallette_colors(animatedSprite)
	
func pallette_weaponget():
	_sprites_pistol_A = pallette_sprites_pistol_A
	_sprites_pistol_B = pallette_sprites_pistol_B
	_sprites_raygun = pallette_sprites_raygun
	_sprites_sprialmagnum_A = pallette_sprites_sprialmagnum_A
	_sprites_spiralmagnum_B = pallette_sprites_spiralmagnum_B
	_sprites_blackarrow = pallette_sprites_blackarrow
	_sprites_plasmagun = pallette_sprites_plasmagun
	_sprites_blastlauncher_A = pallette_sprites_blastlauncher_A
	_sprites_blastlauncher_B = pallette_sprites_blastlauncher_B
	_sprites_boundblaster_A = pallette_sprites_boundblaster_A
	_sprites_boundblaster_B = pallette_sprites_boundblaster_B
	_sprites_icegattling_1 = pallette_sprites_icegattling_1
	_sprites_icegattling_2 = pallette_sprites_icegattling_2
	_sprites_icegattling_3 = pallette_sprites_icegattling_3
	_sprites_icegattling_4 = pallette_sprites_icegattling_4
	_sprites_flameburner = pallette_sprites_flameburner
	
	get_node("animatedSprite").frames = pallette_sprites_pistol_A
	
	get_node("Shot").get_node("Pistol")._sprites_weapon = pallette_sprites_pistol_A
	get_node("Shot").get_node("Pistol")._sprites_weapon_B = pallette_sprites_pistol_B

	get_node("Shot").get_node("RayGun")._sprites_weapon = pallette_sprites_raygun
	get_node("Shot").get_node("RayGun")._sprites_weapon_B = pallette_sprites_raygun

	get_node("Shot").get_node("SpiralMagnum")._sprites_weapon = pallette_sprites_sprialmagnum_A
	get_node("Shot").get_node("SpiralMagnum")._sprites_weapon_B = pallette_sprites_spiralmagnum_B

	get_node("Shot").get_node("BlackArrow")._sprites_weapon = pallette_sprites_blackarrow
	get_node("Shot").get_node("BlackArrow")._sprites_weapon_B = pallette_sprites_blackarrow

	get_node("Shot").get_node("PlasmaGun")._sprites_weapon = pallette_sprites_plasmagun
	get_node("Shot").get_node("PlasmaGun")._sprites_weapon_B = pallette_sprites_plasmagun

	get_node("Shot").get_node("BlastLauncher")._sprites_weapon = pallette_sprites_blastlauncher_A
	get_node("Shot").get_node("BlastLauncher")._sprites_weapon_B = pallette_sprites_blastlauncher_B

	get_node("Shot").get_node("BoundBlaster")._sprites_weapon = pallette_sprites_boundblaster_A
	get_node("Shot").get_node("BoundBlaster")._sprites_weapon_B = pallette_sprites_boundblaster_B

	get_node("Shot").get_node("IceGattling")._sprites_weapon = pallette_sprites_icegattling_1
	get_node("Shot").get_node("IceGattling")._sprites_weapon_B = pallette_sprites_icegattling_2

	get_node("Shot").get_node("FlameBurner")._sprites_weapon = pallette_sprites_flameburner
	get_node("Shot").get_node("FlameBurner")._sprites_weapon_B = pallette_sprites_flameburner

	get_node("AltFire").get_node("Alternate Pistol")._sprites_weapon = pallette_sprites_pistol_A
	get_node("AltFire").get_node("Alternate Pistol")._sprites_weapon_B = pallette_sprites_pistol_B

	get_node("AltFire").get_node("Alternate RayGun")._sprites_weapon = pallette_sprites_raygun
	get_node("AltFire").get_node("Alternate RayGun")._sprites_weapon_B = pallette_sprites_raygun

	get_node("AltFire").get_node("Alternate SpiralMagnum")._sprites_weapon = pallette_sprites_sprialmagnum_A
	get_node("AltFire").get_node("Alternate SpiralMagnum")._sprites_weapon_B = pallette_sprites_spiralmagnum_B

	get_node("AltFire").get_node("Alternate BlackArrow")._sprites_weapon = pallette_sprites_blackarrow
	get_node("AltFire").get_node("Alternate BlackArrow")._sprites_weapon_B = pallette_sprites_blackarrow

	get_node("AltFire").get_node("Alternate PlasmaGun")._sprites_weapon = pallette_sprites_plasmagun
	get_node("AltFire").get_node("Alternate PlasmaGun")._sprites_weapon_B = pallette_sprites_plasmagun

	get_node("AltFire").get_node("Alternate BlastLauncher")._sprites_weapon = pallette_sprites_blastlauncher_A
	get_node("AltFire").get_node("Alternate BlastLauncher")._sprites_weapon_B = pallette_sprites_blastlauncher_B

	get_node("AltFire").get_node("Alternate BoundBlaster")._sprites_weapon = pallette_sprites_boundblaster_A
	get_node("AltFire").get_node("Alternate BoundBlaster")._sprites_weapon_B = pallette_sprites_boundblaster_B

	get_node("AltFire").get_node("Alternate IceGattling")._sprites_weapon = pallette_sprites_icegattling_1
	get_node("AltFire").get_node("Alternate IceGattling")._sprites_weapon_B = pallette_sprites_icegattling_2

	get_node("AltFire").get_node("Alternate FlameBurner")._sprites_weapon = pallette_sprites_flameburner
	get_node("AltFire").get_node("Alternate FlameBurner")._sprites_weapon_B = pallette_sprites_flameburner

func _process(delta: float) -> void :
	if Input.is_action_pressed("fire_emulated") or Input.is_action_pressed("alt_fire_emulated"):
		is_shooting = true
		Event.emit_signal("is_shooting")
	else:
		is_shooting = false
		Event.emit_signal("is_not_shooting")
		var _shot_node = get_node("Shot")
		if _shot_node != null:
			if _shot_node.current_weapon != null:
				if _shot_node.current_weapon.name == "IceGattling":
					if not pallette:
						_shot_node.current_weapon._gattling_sprites = 1
						if animatedSprite.frames != _sprites_icegattling_1:
							animatedSprite.frames = _sprites_icegattling_1
					if pallette:
						_shot_node.current_weapon._gattling_sprites = 1
						if animatedSprite.frames != pallette_sprites_icegattling_1:
							animatedSprite.frames = pallette_sprites_icegattling_1
	if ride_eject_delay >= 0:
		ride_eject_delay -= delta
	process_flash(delta)

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

func equip_axl_parts() -> void :
	spike_invincibility = true
	get_node("JumpDamage").deactivate()
	get_node("LifeSteal").deactivate()
	var dmg = get_node("Damage")
	dmg.active = false
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
	dash.horizontal_velocity = 210
	var airdash = get_node("AirDash")
	airdash.upgraded = false
	airdash.dash_duration = 0.55
	airdash.horizontal_velocity = 210
	airdash.max_airdashes = 1
	airdash.airdash_count = 1
	var hover = get_node("Hover")
	hover.upgraded = false
	hover.horizontal_velocity = 90
	hover.vertical_velocity = 30
	get_node("DashWallJump").horizontal_velocity = 210
	get_node("DashJump").horizontal_velocity = 210
	get_node("Fall").dash_momentum = 210

func equip_axl_white_parts() -> void :
	equip_axl_parts()

func equip_cheat_axl_parts() -> void :
	equip_axl_parts()

func equip_pallette_parts() -> void :
	equip_axl_parts()

func get_action_pressed(action) -> bool:
	if listening_to_inputs:
		return Input.is_action_pressed(action)
	return false

func get_just_pressed_axis() -> int:
	return less_buggy_pressed_dir

func get_pressed_axis() -> int:
	return less_buggy_pressed_dir

func _input(event: InputEvent) -> void :
	if event.is_action_pressed("down_emulated"):
		less_buggy_pressed_dir = 1
	elif event.is_action_released("down_emulated"):
		less_buggy_pressed_dir = 0
	if event.is_action_pressed("up_emulated"):
		less_buggy_pressed_dir = - 1
	elif event.is_action_released("up_emulated"):
		less_buggy_pressed_dir = 0
	if event.is_action_pressed("right_emulated"):
		less_buggy_pressed_dir = 1
	elif event.is_action_released("right_emulated"):
		less_buggy_pressed_dir = 0
	if event.is_action_pressed("left_emulated"):
		less_buggy_pressed_dir = - 1
	elif event.is_action_released("left_emulated"):
		less_buggy_pressed_dir = 0
