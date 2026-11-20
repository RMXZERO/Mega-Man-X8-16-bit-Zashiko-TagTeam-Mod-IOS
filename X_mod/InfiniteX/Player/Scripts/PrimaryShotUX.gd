extends PrimaryShot
class_name PrimaryShotUX

onready var weak = get_parent().get_node("Idle")

var hadoken: bool = false
var shoryuuken: bool = false
var darkarrow: bool = false
var bladegiga: bool = false
var ninjagiga: bool = false
var gigacrash: bool = false
var xdrive: bool = false
var nova_strike: bool = false
var saber: bool = false

func _ready() -> void :
	Event.listen("weapon_select_left", self, "Update_Giga_Crash")
	Event.listen("weapon_select_right", self, "Update_Giga_Crash")
	Event.listen("weapon_select_buster", self, "Update_Giga_Crash")
	Event.connect("pause_menu_closed", self, "Update_Giga_Crash")
	Event.listen("select_weapon", self, "Update_Giga_Crash")

func Update(_weapon_resource) -> void :
	Update_Giga_Crash()

func Update_Giga_Crash(_d = null) -> void :
	hadoken = false
	shoryuuken = false
	darkarrow = false
	bladegiga = false
	ninjagiga = false
	gigacrash = false
	xdrive = false
	nova_strike = false
	saber = false
	if current_weapon.name == "OpticShield":
		hadoken = true
	elif current_weapon.name == "SqueezeBomb":
		shoryuuken = true
	elif current_weapon.name == "DarkArrow":
		darkarrow = true
	elif current_weapon.name == "ThunderDancer":
		bladegiga = true
	elif current_weapon.name == "BlastLauncher":
		ninjagiga = true
	elif current_weapon.name == "CrystalBouncer":
		gigacrash = true
	elif current_weapon.name == "DriftDiamond":
		xdrive = true
	elif current_weapon.name == "FireDash":
		nova_strike = true
	else:
		saber = true
	reset_idle_animation()

func restart_animation() -> void :
	if character.get_animation() == "recover":
		if character.is_low_health() or weak.idle_weak:
			character.animatedSprite.play("shot_recover")
			character.animatedSprite.set_frame(1)
		character.animatedSprite.set_frame(1)

func reset_idle_animation() -> void :
	if character.get_animation() == "recover":
		if character.is_low_health() or weak.idle_weak:
			character.animatedSprite.play("shot_recover")

func fire(weapon):
	if get_parent().is_executing("Hadoken") or \
	get_parent().is_executing("Shoryuuken") or \
	get_parent().is_executing("FalconGiga") or \
	get_parent().is_executing("BladeGiga") or \
	get_parent().is_executing("NinjaGiga") or \
	get_parent().is_executing("GigaCrash") or \
	get_parent().is_executing("NovaStrike") or \
	get_parent().is_executing("SaberCombo"):
		return
	enable_animation_layer()
	restart_animation()
	timer = 0.0
	if character.get_action_pressed("shoryuuken"):
		reset_cooldown()
	if CharacterManager.ultimate_buster and not CharacterManager.weaponget:
		ultimate_buster_level()
	weapon.fire(charge_level)
	charge_level = 0

func ultimate_buster_level() -> void :
	if CharacterManager.ultimate_buster and not ultimate_buster_cooldown and not CharacterManager.weaponget:
		ultimate_buster_cooldown = true
		if CharacterManager.xdrive:
			Tools.timer(charge.level_4_charge * (1 - charge.charge_time_reduction) * 0.5, "reset_cooldown", self)
		else:
			Tools.timer(charge.level_4_charge * (1 - charge.charge_time_reduction), "reset_cooldown", self)
		actions[0] = "shoryuuken"
		charge_level = 3

func reset_cooldown() -> void :
	ultimate_buster_cooldown = false
	actions[0] = "fire"
