extends X8TextureButton

export  var weapon_resource: Resource

onready var weapon_name: Label = get_node("weapon_name")
onready var ammo: TextureProgress = get_node("ammo/current")
onready var zero_icon = $"../../Lives/Zero_icon"
onready var zero_live_icon = $"../../Lives/Zero_lives_icon"
onready var black_zero_icon: TextureRect = $"../../BlackZeroArmor"
onready var zero_base: Texture = preload("res://Zero_mod/HUD/ZeroX8_base.png")
onready var zero_bfan: Texture = preload("res://Zero_mod/HUD/ZeroX8_fan.png")
onready var zero_dglaive: Texture = preload("res://Zero_mod/HUD/ZeroX8_glaive.png")
onready var zero_kknuckle: Texture = preload("res://Zero_mod/HUD/ZeroX8_knuckle.png")
onready var zero_tbreaker: Texture = preload("res://Zero_mod/HUD/ZeroX8_breaker.png")
onready var zero_vhanger: Texture = preload("res://Zero_mod/HUD/ZeroX7_hanger.png")
onready var zero_buster: Texture = preload("res://Zero_mod/HUD/Zero_buster.png")
onready var zero_sigmablade: Texture = preload("res://Zero_mod/HUD/ZeroX8_sigmablade.png")
onready var zero_rogueblade: Texture = preload("res://Zero_mod/HUD/MegamanSF2_rogueblade.png")
onready var zero_genmu: Texture = preload("res://Zero_mod/HUD/ZeroX8_base.png")

onready var zero_beta: Texture = preload("res://Zero_mod/HUD/Zero_base.png")
onready var black_zero_beta_icon: Texture = preload("res://Zero_mod/HUD/Pause/beta_black_zero_collectible.png")
onready var zero_beta_material: = preload("res://Zero_mod/X8/Sprites/ZeroX8_Material_Shader.tres")

var character_name = "Zero"
var weapon


func _ready() -> void :
	call_deferred("set_player_weapon")
	call_deferred("connect_switch_weapon")
	Event.listen("customzerocolor", self, "on_start")
	var _s = menu.connect("pause_starting", self, "on_start")
	if weapon_resource:
		weapon_name.text = tr(weapon_resource.short_name)
		texture_normal = weapon_resource.icon
		pass

func on_start() -> void :
	ammo.value = get_bar_value()
	CharacterManager.set_zeroX8_colors(zero_icon)
	CharacterManager.set_zeroX8_colors(zero_live_icon)
	if CharacterManager.betazero_activated:
		zero_icon.texture = zero_beta
		black_zero_icon.texture = black_zero_beta_icon
		zero_icon.material = zero_beta_material
		CharacterManager.set_zero_colors(zero_icon)
		CharacterManager.set_zero_colors(zero_live_icon)

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
		if zero_icon.texture == zero_bfan:
			get_parent().get_node("B-Fan").set_last_weapon()
		elif zero_icon.texture == zero_dglaive:
			get_parent().get_node("D-Glaive").set_last_weapon()
		elif zero_icon.texture == zero_kknuckle:
			get_parent().get_node("K-Knuckle").set_last_weapon()
		elif zero_icon.texture == zero_tbreaker:
			get_parent().get_node("T-Breaker").set_last_weapon()
		elif zero_icon.texture == zero_vhanger:
			get_parent().get_node("V-Hanger").set_last_weapon()
		elif zero_icon.texture == zero_sigmablade:
			get_parent().get_node("Sigma-Blade").set_last_weapon()
		elif zero_icon.texture == zero_buster:
			get_parent().get_node("Z-Breaker").set_last_weapon()
		elif zero_icon.texture == zero_rogueblade:
			get_parent().get_node("Rogue-Blade").set_last_weapon()
		else:
			get_parent().get_node("Saber").set_last_weapon()

func set_last_weapon() -> void :
	if CharacterManager.player_character != "Zero":
		return
	if CharacterManager.betazero_activated:
		return
	if self.name == "Genmu Zero":
		return
	if GameManager.is_player_in_scene():
		var _shot_node = GameManager.player.get_node("Shot")
		if _shot_node != null:
			var _animation = _shot_node.get_parent().get_animation()
			if _animation in _shot_node.get_parent().saber_animations:
				return
			_shot_node.set_current_weapon(weapon)
	get_parent().set_weapon(self)
	set_pause_icon(weapon)

func get_bar_value() -> float:
	if self.name == "Genmu Zero" and CharacterManager.player_character == "Zero" and GameManager.is_player_in_scene():
		var _weapon = GameManager.player.get_node("Special").current_weapon
		if _weapon:
			return inverse_lerp(0.0, _weapon.max_ammo, _weapon.current_ammo) * 74
	if weapon:
		return inverse_lerp(0.0, weapon.max_ammo, weapon.current_ammo) * 28
	return 28.0

func set_pause_icon(_weapon) -> void :
	if not _weapon:
		zero_icon.texture = zero_base
	else:
		if weapon.name == "B-Fan":
			zero_icon.texture = zero_bfan
		if weapon.name == "D-Glaive":
			zero_icon.texture = zero_dglaive
		if weapon.name == "K-Knuckle":
			zero_icon.texture = zero_kknuckle
		if weapon.name == "T-Breaker":
			zero_icon.texture = zero_tbreaker
		if weapon.name == "V-Hanger":
			zero_icon.texture = zero_vhanger
		if weapon.name == "Sigma-Blade":
			zero_icon.texture = zero_sigmablade
		if weapon.name == "Z-Breaker":
			zero_icon.texture = zero_buster
		if weapon.name == "Rogue-Blade":
			zero_icon.texture = zero_rogueblade
		if weapon.name == "Genmuzero":
			zero_icon.texture = zero_genmu
	if CharacterManager.betazero_activated:
		zero_icon.texture = zero_beta
		black_zero_icon.texture = black_zero_beta_icon

func set_player_weapon() -> void :
	if weapon_resource and GameManager.player:
		var i = CharacterManager.team.find(character_name)
		for _weapon in GameManager.team[i].get_node("Shot").get_children():
			if _weapon is ZeroSpecialWeapon:
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
