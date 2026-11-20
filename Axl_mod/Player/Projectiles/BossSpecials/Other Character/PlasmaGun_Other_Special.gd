extends Node2D

onready var main: = $".."
onready var character: = get_parent().get_parent()
onready var animatedSprite: AnimatedSprite = $animatedSprite
var aura_show: bool = false
var end_ability: bool = false

onready var player_damage: = character.get_node("Damage")
onready var player_walk: = character.get_node("Walk")
onready var player_jump: = character.get_node("Jump")
onready var player_walljump: = character.get_node("WallJump")
onready var player_wallslide: = character.get_node("WallSlide")
onready var player_dash: = character.get_node("Dash")
onready var player_airdash: = character.get_node("AirDash")
onready var player_dashjump: = character.get_node("DashJump")
onready var player_dashwalljump: = character.get_node("DashWallJump")
onready var player_fall: = character.get_node("Fall")

onready var player_saber_jump: = character.get_node_or_null("SaberJump")#only Zero and Layer
onready var player_saber_dash: = character.get_node_or_null("SaberDash")#only Zero and Layer
onready var player_rasetsusen: = character.get_node_or_null("Rasetsusen")#only Zero and Layer
onready var player_knuckle_jump: = character.get_node_or_null("KnuckleJump")#only Zero and Layer but not Beta Zero
onready var player_knuckle_dash: = character.get_node_or_null("KnuckleDash")#only Zero and Layer but not Beta Zero

onready var player_doublejump: = character.get_node_or_null("AirJump")#Axl and Pallette not have it

onready var player_hover: = character.get_node_or_null("Hover")#only Axl and Pallette
onready var player_dodge: = character.get_node_or_null("Dodge")#only Axl and Pallette

onready var player_saber_combo: =  character.get_node_or_null("SaberCombo")#Infinite X
onready var player_desperation: =  character.get_node_or_null("Desperation")#Infinite X


var aura_time: float = 13.0
var speed_factor: float = 1.5
var height_factor: float = 1.15
var gravity_factor: float = 0.85
var debuff_time: float = 3.0
var flash_time: float = 0.125
var flash_timer: float = 0.0
var debuff_speed_factor: float = 0.75
var debuff_height_factor: float = 0.85
var debuff_gravity_factor: float = 1.0
var default_gravity: float = 900.0
var sfx_play_time: float = 0.0

var walk_speed: float
var jump_speed: float
var walljump_speed: float
var wallslide_speed: float
var dash_speed: float
var airdash_speed: float
var dashjump_speed: float
var dashwalljump_speed: float

var fall_speed: float
var dashfall_speed: float
var jump_time: float
var dashjumptime: float
var walljumptime: float
var dashwalljump_time: float

var saber_dash_speed: float
var saber_jump_speed: float
var knuckle_dash_speed: float
var desperation_speed: float

#var airjump_default_gravity: float
var airjumptime: float
var airjump_speed: float
var dashairjump_speed: float

var hover_speed: float
var hover_speed2: float
var dodge_speed: float

func _ready() -> void :
	Event.listen("axl_special_ability", self, "ability_parts")

func ability_parts(ability_name: String):
	if not aura_show:
		backup_original_values()
	if not CharacterManager.share_axl_buff or not "share_axl_buff" in GameManager.collectibles:
		aura_show = false
		animatedSprite.hide()
		unset_aura_buff()
	if ability_name == "plasmagun":
		aura_show = true
		end_ability = false
		animatedSprite.show()
		aura_time = 13
		set_aura_buff()
	else:
		aura_show = false
		animatedSprite.hide()
		unset_aura_buff()

func _physics_process(delta: float) -> void :
	if aura_show:
		animatedSprite.scale.x *= - 1
		animatedSprite.scale.y *= - 1
		sfx_play_time -= delta
		if sfx_play_time <= 0:
			sfx_play_time = 0.0625
		aura_time -= delta
		if aura_time <= 0:
			animatedSprite.hide()
			end_ability = true
			unset_aura_buff()
			set_aura_debuff()

	if end_ability:
		end_ability = false
		flash_timer -= delta
		if flash_timer <= 0:
			flash_timer = flash_time
			character.flash()

func set_aura_buff() -> void :
	backup_original_values()
	
	player_walk.horizontal_velocity *= speed_factor
	player_jump.horizontal_velocity *= speed_factor
	player_walljump.horizontal_velocity *= speed_factor
	player_dash.horizontal_velocity *= speed_factor
	player_airdash.horizontal_velocity *= speed_factor
	player_dashjump.horizontal_velocity *= speed_factor
	player_dashwalljump.horizontal_velocity *= speed_factor

	player_fall.horizontal_velocity *= speed_factor
	player_wallslide.jump_velocity *= gravity_factor
	
	player_jump.max_jump_time *= height_factor
	player_walljump.max_jump_time *= height_factor
	player_dashjump.max_jump_time *= height_factor
	player_dashwalljump.max_jump_time *= height_factor
	
	player_walk.default_gravity *= gravity_factor
	player_jump.default_gravity *= gravity_factor
	player_walljump.default_gravity *= gravity_factor

	player_wallslide.default_gravity *= gravity_factor
	player_dash.default_gravity *= gravity_factor
	player_airdash.default_gravity *= gravity_factor
	player_dashjump.default_gravity *= gravity_factor
	player_dashwalljump.default_gravity *= gravity_factor
	player_fall.default_gravity *= gravity_factor
	
	if not main.player_pallette:
		#player_doublejump.default_gravity *= gravity_factor
		player_doublejump.max_jump_time *= height_factor
		player_doublejump.horizontal_velocity *= speed_factor
		if main.player_x or main.player_alia:
			player_doublejump.dash_momentum *= speed_factor
			player_jump.dash_momentum *= speed_factor
		if main.player_zero or main.player_layer:
			player_doublejump.dashjump_speed *= speed_factor
	
	if main.player_zero or main.player_layer:
		player_fall.dashjump_speed *= speed_factor
		
		player_saber_dash.horizontal_velocity *= speed_factor
		player_saber_jump.dashjump_speed *= speed_factor
		player_rasetsusen.dashjump_speed *= speed_factor
		if not main.player_zero_beta:
			player_knuckle_dash.start_speed *= speed_factor
			player_knuckle_jump.dashjump_speed *= speed_factor
		
	if not main.player_zero and not main.player_layer:
		player_fall.dash_momentum *= speed_factor
	
	if main.player_pallette or main.player_infinite_x:
		player_hover.horizontal_velocity *= speed_factor
		player_hover.vertical_velocity *= speed_factor
		player_hover.default_gravity *= gravity_factor
		if main.player_pallette:
			player_dodge.default_gravity *= gravity_factor
			player_dodge.horizontal_velocity *= speed_factor

	if main.player_infinite_x:
		player_saber_combo.dash_momentum *= speed_factor

	if not player_desperation == null:
		player_desperation.desperation_speed *= speed_factor

func set_aura_debuff() -> void :
	
	player_walk.horizontal_velocity *= debuff_speed_factor
	player_jump.horizontal_velocity *= debuff_speed_factor
	player_walljump.horizontal_velocity *= debuff_speed_factor
	player_dash.horizontal_velocity *= debuff_speed_factor
	player_airdash.horizontal_velocity *= debuff_speed_factor
	player_dashjump.horizontal_velocity *= debuff_speed_factor
	player_dashwalljump.horizontal_velocity *= debuff_speed_factor
	player_fall.horizontal_velocity *= debuff_speed_factor
	player_wallslide.jump_velocity *= debuff_gravity_factor
	
	player_jump.max_jump_time *= debuff_height_factor
	player_walljump.max_jump_time *= debuff_height_factor
	player_dashjump.max_jump_time *= debuff_height_factor
	player_dashwalljump.max_jump_time *= debuff_height_factor
	
	player_walk.default_gravity *= debuff_gravity_factor
	player_jump.default_gravity *= debuff_gravity_factor
	player_walljump.default_gravity *= debuff_gravity_factor

	player_wallslide.default_gravity *= debuff_gravity_factor
	player_dash.default_gravity *= debuff_gravity_factor
	player_airdash.default_gravity *= debuff_gravity_factor
	player_dashjump.default_gravity *= debuff_gravity_factor
	player_dashwalljump.default_gravity *= debuff_gravity_factor

	player_fall.default_gravity *= debuff_gravity_factor

	if not main.player_pallette:
		#player_doublejump.default_gravity *= debuff_gravity_factor
		player_doublejump.max_jump_time *= debuff_height_factor
		player_doublejump.horizontal_velocity *= debuff_speed_factor
		if main.player_x or main.player_alia:
			player_doublejump.dash_momentum *= debuff_speed_factor
			player_jump.dash_momentum *= debuff_speed_factor
		if main.player_zero or main.player_layer:
			player_doublejump.dashjump_speed *= debuff_speed_factor

	if main.player_zero or main.player_layer:
		player_fall.dashjump_speed *= debuff_speed_factor
		
		player_saber_dash.horizontal_velocity *= debuff_speed_factor
		player_saber_jump.dashjump_speed *= debuff_speed_factor
		player_rasetsusen.dashjump_speed *= debuff_speed_factor
		if not main.player_zero_beta:
			player_knuckle_dash.start_speed *= debuff_speed_factor
			player_knuckle_jump.dashjump_speed *= debuff_speed_factor
		
	if not main.player_zero and not main.player_layer:
		player_fall.dash_momentum *= debuff_speed_factor

	if main.player_pallette or main.player_infinite_x:
		player_hover.horizontal_velocity *= debuff_speed_factor
		player_hover.vertical_velocity *= debuff_speed_factor
		player_hover.default_gravity *= debuff_gravity_factor
		if main.player_pallette:
			player_dodge.default_gravity *= debuff_gravity_factor
			player_dodge.horizontal_velocity *= debuff_speed_factor

	if main.player_infinite_x:
		player_saber_combo.dash_momentum *= debuff_speed_factor

	if not player_desperation == null:
		player_desperation.desperation_speed *= debuff_speed_factor

func unset_aura_buff() -> void :
	restore_original_values()

func restore_original_values() -> void :
	
	player_walk.horizontal_velocity = walk_speed
	player_jump.horizontal_velocity = jump_speed
	player_walljump.horizontal_velocity = walljump_speed
	player_dash.horizontal_velocity = dash_speed
	player_airdash.horizontal_velocity = airdash_speed
	player_dashjump.horizontal_velocity = dashjump_speed
	player_dashwalljump.horizontal_velocity = dashwalljump_speed
	player_fall.horizontal_velocity = fall_speed

	player_wallslide.jump_velocity = wallslide_speed
	
	player_jump.max_jump_time = jump_time
	player_walljump.max_jump_time = walljumptime
	player_dashjump.max_jump_time = dashjumptime
	player_dashwalljump.max_jump_time = dashwalljump_time
	
	player_walk.default_gravity = default_gravity
	player_jump.default_gravity = default_gravity
	player_walljump.default_gravity = default_gravity
	player_wallslide.default_gravity = default_gravity
	player_dash.default_gravity = default_gravity
	player_airdash.default_gravity = default_gravity
	player_dashjump.default_gravity = default_gravity
	player_dashwalljump.default_gravity = default_gravity
	player_fall.default_gravity = default_gravity
	
	if not main.player_pallette:
		#player_doublejump.default_gravity *= airjump_default_gravity
		player_doublejump.max_jump_time = airjumptime
		player_doublejump.horizontal_velocity = airjump_speed
		if main.player_x or main.player_alia:
			player_doublejump.dash_momentum = dashairjump_speed
		if main.player_zero or main.player_layer:
			player_doublejump.dashjump_speed = dashairjump_speed
	
	if main.player_zero or main.player_layer:
		player_fall.dashjump_speed = dashfall_speed
		
		player_saber_dash.horizontal_velocity = saber_dash_speed
		player_saber_jump.dashjump_speed = saber_jump_speed
		player_rasetsusen.dashjump_speed = saber_jump_speed
		if not main.player_zero_beta:
			player_knuckle_dash.start_speed = knuckle_dash_speed
			player_knuckle_jump.dashjump_speed = saber_jump_speed

	if not main.player_zero and not main.player_layer:
		player_fall.dash_momentum = dashfall_speed

	if main.player_pallette or main.player_infinite_x:
		player_hover.horizontal_velocity = hover_speed
		player_hover.vertical_velocity = hover_speed2
		player_hover.default_gravity = default_gravity
		if main.player_pallette:
			player_dodge.default_gravity = default_gravity
			player_dodge.horizontal_velocity = dodge_speed

	if main.player_infinite_x:
		player_saber_combo.dash_momentum = saber_jump_speed

	if not player_desperation == null:
		player_desperation.desperation_speed = desperation_speed

func backup_original_values() -> void :
	
	walk_speed = player_walk.horizontal_velocity
	jump_speed = player_jump.horizontal_velocity
	walljump_speed = player_walljump.horizontal_velocity

	dash_speed = player_dash.horizontal_velocity
	airdash_speed = player_airdash.horizontal_velocity
	dashjump_speed = player_dashjump.horizontal_velocity
	dashwalljump_speed = player_dashwalljump.horizontal_velocity

	fall_speed = player_fall.horizontal_velocity
	wallslide_speed = player_wallslide.jump_velocity
	
	jump_time = player_jump.max_jump_time
	walljumptime = player_walljump.max_jump_time
	dashjumptime = player_dashjump.max_jump_time
	dashwalljump_time = player_dashwalljump.max_jump_time
	
	if not main.player_pallette:
		#airjump_default_gravity = player_doublejump.default_gravity
		airjumptime = player_doublejump.max_jump_time
		airjump_speed = player_doublejump.horizontal_velocity
		if main.player_x or main.player_alia:
			dashairjump_speed = player_doublejump.dash_momentum
		if main.player_zero or main.player_layer:
			dashairjump_speed = player_doublejump.dashjump_speed
			
	
	if main.player_zero or main.player_layer:
		dashfall_speed = player_fall.dashjump_speed
		saber_dash_speed = player_saber_dash.horizontal_velocity
		saber_jump_speed = player_saber_jump.dashjump_speed
		if not main.player_zero_beta:
			knuckle_dash_speed = player_knuckle_dash.start_speed
		
	if not main.player_zero and not main.player_layer:
		dashfall_speed = player_fall.dash_momentum
	
	if main.player_pallette or main.player_infinite_x:
		hover_speed = player_hover.horizontal_velocity
		hover_speed2 = player_hover.vertical_velocity
		if main.player_pallette:
			dodge_speed = player_dodge.horizontal_velocity
	
	if main.player_infinite_x:
		saber_jump_speed = player_saber_combo.dash_momentum
		
	if not player_desperation == null:
		desperation_speed = player_desperation.desperation_speed


