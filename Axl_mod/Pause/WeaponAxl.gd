extends X8TextureButton

export  var weapon_resource: Resource

onready var weapon_name: Label = get_node("weapon_name")
onready var ammo: TextureProgress = get_node("ammo/current")
onready var axl_icon = get_parent().get_parent().get_node("Lives").get_node("Axl_icon")
onready var axl_base: Texture = preload("res://Axl_mod/HUD/Pause/Axl_base.png")
onready var axl_raygun: Texture = preload("res://Axl_mod/HUD/Pause/Axl_raygun.png")
onready var axl_sprial: Texture = preload("res://Axl_mod/HUD/Pause/Axl_spiralmagnum.png")
onready var axl_blacka: Texture = preload("res://Axl_mod/HUD/Pause/Axl_blackarrow.png")
onready var axl_plasma: Texture = preload("res://Axl_mod/HUD/Pause/Axl_plasmagun.png")
onready var axl_blastl: Texture = preload("res://Axl_mod/HUD/Pause/Axl_blastlauncher.png")
onready var axl_boundb: Texture = preload("res://Axl_mod/HUD/Pause/Axl_boundblaster.png")
onready var axl_icegat: Texture = preload("res://Axl_mod/HUD/Pause/Axl_icegattling.png")
onready var axl_flameb: Texture = preload("res://Axl_mod/HUD/Pause/Axl_flameburner.png")

var character_name = "Axl"
var weapon


func _ready() -> void :
	call_deferred("set_player_weapon")
	call_deferred("connect_switch_weapon")
	var _s = menu.connect("pause_starting", self, "on_start")
	if weapon_resource:
		weapon_name.text = tr(weapon_resource.short_name)
		texture_normal = weapon_resource.icon

func on_start() -> void :
	ammo.value = get_bar_value()

func connect_switch_weapon() -> void :
	Event.connect("character_switch", self, "load_last_weapon")
	Event.connect("weapon_select_buster", self, "save_last_weapon")
	Event.connect("weapon_select_right", self, "save_last_weapon")
	Event.connect("weapon_select_left", self, "save_last_weapon")
	Event.connect("select_weapon", self, "save_last_weapon")

func save_last_weapon(_d = null) -> void :
	get_parent().show_weapons()

func load_last_weapon() -> void :
	if is_instance_valid(GameManager.player):
		if axl_icon.texture == axl_raygun:
			get_parent().get_node("sunflower_weapon").set_last_weapon()
		elif axl_icon.texture == axl_sprial:
			get_parent().get_node("antonion_weapon").set_last_weapon()
		elif axl_icon.texture == axl_blacka:
			get_parent().get_node("mantis_weapon").set_last_weapon()
		elif axl_icon.texture == axl_plasma:
			get_parent().get_node("manowar_weapon").set_last_weapon()
		elif axl_icon.texture == axl_blastl:
			get_parent().get_node("panda_weapon").set_last_weapon()
		elif axl_icon.texture == axl_boundb:
			get_parent().get_node("trilobyte_weapon").set_last_weapon()
		elif axl_icon.texture == axl_icegat:
			get_parent().get_node("yeti_weapon").set_last_weapon()
		elif axl_icon.texture == axl_flameb:
			get_parent().get_node("rooster_weapon").set_last_weapon()
		else:
			get_parent().get_node("Pistol").set_last_weapon()

func set_last_weapon() -> void :
	if CharacterManager.player_character != "Axl":
		return
	if GameManager.player.is_executing("SaberCombo"):
		return
	if self.name == "Giga Impact":
		return
	if GameManager.is_player_in_scene():
		var _shot_node = GameManager.player.get_node("Shot")
		if _shot_node != null:
			_shot_node.set_current_weapon(weapon)
	get_parent().set_weapon(self)
	set_pause_icon(weapon)

func get_bar_value() -> float:
	if self.name == "Giga Impact" and CharacterManager.player_character == "Axl" and GameManager.is_player_in_scene():
		var _weapon = GameManager.player.get_node("Special").get_node("GigaCrash")
		if _weapon:
			return inverse_lerp(0.0, _weapon.max_ammo, _weapon.current_ammo) * 74
	if weapon:
		return inverse_lerp(0.0, weapon.max_ammo, weapon.current_ammo) * 28
	return 28.0

func set_pause_icon(_weapon) -> void :
	if axl_icon != null:
		if not _weapon:
			axl_icon.texture = axl_base
		else:
			if weapon.name == "RayGun":
				axl_icon.texture = axl_raygun
			elif weapon.name == "SpiralMagnum":
				axl_icon.texture = axl_sprial
			elif weapon.name == "BlackArrow":
				axl_icon.texture = axl_blacka
			elif weapon.name == "PlasmaGun":
				axl_icon.texture = axl_plasma
			elif weapon.name == "BlastLauncher":
				axl_icon.texture = axl_blastl
			elif weapon.name == "BoundBlaster":
				axl_icon.texture = axl_boundb
			elif weapon.name == "IceGattling":
				axl_icon.texture = axl_icegat
			elif weapon.name == "FlameBurner":
				axl_icon.texture = axl_flameb

func set_player_weapon() -> void :
	if weapon_resource and GameManager.player:
		var i = CharacterManager.team.find(character_name)
		for _weapon in GameManager.team[i].get_node("Shot").get_children():
			if _weapon is WeaponBossAxl or _weapon.name == "GigaCrash" or _weapon.name == "XDrive":
				if _weapon.weapon.collectible == weapon_resource.collectible:
					weapon = _weapon

func _on_focus_entered() -> void :
	._on_focus_entered()
	set_last_weapon()

func _on_focus_exited() -> void :
	if get_parent().choosen_weapon != self:
		._on_focus_exited()

func on_press() -> void :
	pass
