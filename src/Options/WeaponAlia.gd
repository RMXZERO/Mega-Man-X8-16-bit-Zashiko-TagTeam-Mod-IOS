extends X8TextureButton

export  var weapon_resource: Resource

onready var weapon_name: Label = get_node("weapon_name")
onready var ammo: TextureProgress = get_node("ammo/current")

var character_name = "Alia"
var last_weapon: String
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
	if CharacterManager.player_character != "Alia":
		return
	if GameManager.is_player_in_scene():
		var arm_cannon = GameManager.player.get_node("Shot")
		if arm_cannon.current_weapon.name == "OpticShield":
			last_weapon = "sunflower_weapon"
		elif arm_cannon.current_weapon.name == "SqueezeBomb":
			last_weapon = "antonion_weapon"
		elif arm_cannon.current_weapon.name == "DarkArrow":
			last_weapon = "mantis_weapon"
		elif arm_cannon.current_weapon.name == "ThunderDancer":
			last_weapon = "manowar_weapon"
		elif arm_cannon.current_weapon.name == "BlastLauncher":
			last_weapon = "panda_weapon"
		elif arm_cannon.current_weapon.name == "CrystalBouncer":
			last_weapon = "trilobyte_weapon"
		elif arm_cannon.current_weapon.name == "DriftDiamond":
			last_weapon = "yeti_weapon"
		elif arm_cannon.current_weapon.name == "FireDash":
			last_weapon = "rooster_weapon"
		else:
			last_weapon = "Buster"

func load_last_weapon() -> void :
	if is_instance_valid(GameManager.player):
		if last_weapon == "sunflower_weapon":
			get_parent().get_node("sunflower_weapon").set_last_weapon()
		elif last_weapon == "antonion_weapon":
			get_parent().get_node("antonion_weapon").set_last_weapon()
		elif last_weapon == "mantis_weapon":
			get_parent().get_node("mantis_weapon").set_last_weapon()
		elif last_weapon == "manowar_weapon":
			get_parent().get_node("manowar_weapon").set_last_weapon()
		elif last_weapon == "panda_weapon":
			get_parent().get_node("panda_weapon").set_last_weapon()
		elif last_weapon == "trilobyte_weapon":
			get_parent().get_node("trilobyte_weapon").set_last_weapon()
		elif last_weapon == "yeti_weapon":
			get_parent().get_node("yeti_weapon").set_last_weapon()
		elif last_weapon == "rooster_weapon":
			get_parent().get_node("rooster_weapon").set_last_weapon()
		else:
			get_parent().get_node("Alia Buster").set_last_weapon()

func set_last_weapon() -> void :
	if CharacterManager.player_character != "Alia":
		return
	if GameManager.is_player_in_scene():
		GameManager.player.get_node("Shot").set_current_weapon(weapon)
	get_parent().set_weapon(self)
	save_last_weapon()

func get_bar_value() -> float:
	if weapon:
		return inverse_lerp(0.0, weapon.max_ammo, weapon.current_ammo) * 28
	return 28.0

func set_player_weapon() -> void :
	if weapon_resource and GameManager.player:
		var i = CharacterManager.team.find(character_name)
		for _weapon in GameManager.team[i].get_node("Shot").get_children():
			if _weapon is BossWeapon or _weapon.name == "GigaCrash" or _weapon.name == "XDrive" or _weapon.name == "NovaStrike":
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
