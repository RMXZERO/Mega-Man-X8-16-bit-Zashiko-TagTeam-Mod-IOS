extends Node2D

onready var main: = $".."
onready var character: = get_parent().get_parent()
var aura_show: bool = false

onready var player_damage: = character.get_node("Damage")
onready var player_jump: = character.get_node("Jump")
onready var player_dashjump: = character.get_node("DashJump")
onready var player_walljump: = character.get_node("WallJump")
onready var player_dashwalljump: = character.get_node("DashWallJump")

onready var player_doublejump: = character.get_node_or_null("AirJump")#Axl and Pallette not have it

var timestop_time: float = 10.0
var gravity_factor: float = 1.5
var jump_time: float
var dashjumptime: float
var airjumptime: float
var walljumptime: float
var dashwalljump_time: float
var max_fall_velocity: float

func _ready() -> void :
	Event.listen("axl_special_ability", self, "ability_parts")

func ability_parts(ability_name: String):
	if not aura_show:
		backup_original_values()
	if not CharacterManager.share_axl_buff or not "share_axl_buff" in GameManager.collectibles:
		aura_show = false
		unset_aura_buff()
	if ability_name == "spiramagnum":
		aura_show = true
		set_aura_buff()
	else:
		aura_show = false
		unset_aura_buff()

func set_aura_buff() -> void :
	Engine.time_scale = clamp(2.0 - gravity_factor, 0.25, 1.0)
	character.time_stop_active = true
	backup_original_values()
	player_jump.max_jump_time *= gravity_factor
	player_walljump.max_jump_time *= gravity_factor
	player_dashjump.max_jump_time *= gravity_factor
	player_dashwalljump.max_jump_time *= gravity_factor
	character.maximum_fall_velocity *= clamp(2.0 - gravity_factor, 0.25, 1.0)
	if not player_doublejump == null:
		player_doublejump.max_jump_time *= gravity_factor

func unset_aura_buff() -> void :
	Engine.time_scale = 1.0
	character.time_stop_active = false
	restore_original_values()

func restore_original_values() -> void :
	player_jump.max_jump_time = jump_time
	player_walljump.max_jump_time = walljumptime
	player_dashjump.max_jump_time = dashjumptime
	player_dashwalljump.max_jump_time = dashwalljump_time
	character.maximum_fall_velocity = max_fall_velocity
	if not player_doublejump == null:
		player_doublejump.max_jump_time = airjumptime

func backup_original_values() -> void :
	jump_time = player_jump.max_jump_time
	walljumptime = player_walljump.max_jump_time
	dashjumptime = player_dashjump.max_jump_time
	dashwalljump_time = player_dashwalljump.max_jump_time
	max_fall_velocity = character.maximum_fall_velocity
	if not player_doublejump == null:
		airjumptime = player_doublejump.max_jump_time
		
