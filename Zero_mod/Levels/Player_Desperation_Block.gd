extends Node2D
class_name PlayerDesperationBlocking

export  var active: bool = false
export  var difficulty_minumum: int = 0
export  var need_no_damage: bool = false
export  var need_all_weapons: bool = false
export  var need_all_zero_weapons: bool = false
export  var need_all_armors: bool = false
export  var need_all_life_up: bool = false
export  var need_all_subtank: bool = false
export  var need_defeat_secret_boss: bool = false
export  var collectible: String = ""
export  var block_if_collected: bool = true

onready var desperation_limit: = $"../../Limits/Desperation_Limit"
onready var desperation_blocking_wall: CollisionShape2D = $collisionShape2D
onready var desperation_blocking_wall2: CollisionShape2D = $collisionShape2D2

var player_desperation_unlocked: bool = true

var all_armors: Array = [
	"hermes_head", 
	"hermes_arms", 
	"hermes_body", 
	"hermes_legs", 
	"icarus_head", 
	"icarus_arms", 
	"icarus_body", 
	"icarus_legs", 
	"ultima_head", 
	"ultima_body", 
	"ultima_arms", 
	"ultima_legs", 
	"black_zero_armor", 
	"white_axl_armor", 
	]

var all_subtank: Array = [
	"subtank_trilobyte", 
	"subtank_sunflower", 
	"subtank_yeti", 
	"subtank_rooster", 
	]

var all_life_up: Array = [
	"life_up_panda", 
	"life_up_sunflower", 
	"life_up_trilobyte", 
	"life_up_manowar", 
	"life_up_yeti", 
	"life_up_rooster", 
	"life_up_antonion", 
	"life_up_mantis", 
	"life_up_ex1", 
	"life_up_ex2", 
	"life_up_ex3", 
	"life_up_ex4", 
	]

var zero_weapon: Array = [
	"b_fan_zero", 
	"d_glaive_zero", 
	"k_knuckle_zero", 
	"t_breaker_zero", 
	"z_breaker_zero", 
	"rogue_blade_zero", 
	"v_hanger_zero", 
	"sigma_blade_zero", 
	]

var extra_part: Array = [
	"extra_saber_combo", 
	"track_bullet", 
	"share_axl_buff", 
	]

var boss_defeated: Array = [
	"x_defeated", 
	"zero_defeated", 
	"axl_defeated", 
	]

func _ready() -> void :
	if active:
		Event.connect("damage", self, "need_no_damage")
		call_deferred("desperation_block_wall")
		Event.connect("collected", self, "desperation_block_wall")
		Event.connect("capsule_open", self, "on_block_event")

func desperation_block_wall(_n = null) -> void :
	if block_if_collected:
		if collectible != "":
			if collectible in GameManager.collectibles:
				player_desperation_unlocked = false
	
	if need_all_weapons and not got_all_boss_weapons():
		player_desperation_unlocked = false
		print("not got all boss weapons")
	
	if need_all_zero_weapons and not got_all_zero_weapons():
		player_desperation_unlocked = false
		print("not got all zero weapons")
	
	if need_all_armors and not check_for_armors():
		player_desperation_unlocked = false
		print("not got all armors")
		
	if need_all_life_up and not check_life_up():
		player_desperation_unlocked = false
		print("not got all life_up")
		
	if need_all_subtank and not check_life_up():
		player_desperation_unlocked = false
		print("not got all life_up")
	
	if need_defeat_secret_boss and not check_defeat_secret_boss():
		player_desperation_unlocked = false
		print("need defeat boss x zero and axl")
	
	if CharacterManager.game_mode < difficulty_minumum:
		player_desperation_unlocked = false
		print("not difficulty minumum")

	desperation_blocking_wall.disabled = player_desperation_unlocked
	desperation_blocking_wall2.disabled = player_desperation_unlocked

func _process(_delta: float) -> void:
	if Configurations.get("ShowDebug"):
		on_block_event()
	if CharacterManager.teleport_to_boss:
		on_block_event()

func need_no_damage() -> void :
	if need_no_damage:
		on_block_event()
		Event.disconnect("collected", self, "desperation_block_wall")
		Event.disconnect("capsule_open", self, "on_block_event")
		Event.disconnect("damage", self, "need_no_damage")
		on_block_event()

func on_block_event() -> void :
	desperation_limit.disabled = true
	desperation_blocking_wall.set_deferred("disabled", false)
	desperation_blocking_wall2.set_deferred("disabled", false)

func unlock_event() -> void :
	desperation_limit.disabled = false
	desperation_blocking_wall.set_deferred("disabled", true)
	desperation_blocking_wall2.set_deferred("disabled", true)

func check_subtank() -> bool:
	var total_items = 0.0
	var collected_items = 0.0
	for item in all_subtank:
		total_items += 1
		if item in GameManager.collectibles:
			collected_items += 1
	if total_items == collected_items:
		return true
	return false

func check_defeat_secret_boss() -> bool:
	var total_items = 0.0
	var collected_items = 0.0
	for item in boss_defeated:
		total_items += 1
		if item in GameManager.collectibles:
			collected_items += 1
	if total_items == collected_items:
		return true
	return false

func check_life_up() -> bool:
	var total_items = 0.0
	var collected_items = 0.0
	for item in all_life_up:
		total_items += 1
		if item in GameManager.collectibles:
			collected_items += 1
	if total_items == collected_items:
		return true
	return false

func check_for_armors() -> bool:
	var total_items = 0.0
	var collected_items = 0.0
	for item in all_armors:
		total_items += 1
		if item in GameManager.collectibles:
			collected_items += 1
	if total_items == collected_items:
		return true
	return false

func got_all_boss_weapons() -> bool:
	var unlocked_weapons = 0
	for item in GameManager.collectibles:
		if "_weapon" in item and not "boss_weapon" in item:
			unlocked_weapons += 1
	if unlocked_weapons >= 8:
		return true
	return false

func got_all_zero_weapons() -> bool:
	var total_items = 0.0
	var collected_items = 0.0
	for item in zero_weapon:
		total_items += 1
		if item in GameManager.collectibles:
			collected_items += 1
	if total_items == collected_items:
		return true
	return false

