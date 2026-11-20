extends Node2D

onready var main: = $".."
onready var character: = get_parent().get_parent()
onready var player_damage: = character.get_node("Damage")
onready var player_lifesteal: = character.get_node("LifeSteal")
onready var player_dashwalljump: = character.get_node("DashWallJump")
onready var player_dash: = character.get_node("Dash")
onready var player_dashjump: = character.get_node("DashJump")
onready var player_airdash: = character.get_node("AirDash")

onready var player_doublejump: = character.get_node_or_null("AirJump")#Axl and Pallette not have it

onready var player_hover: = character.get_node_or_null("Hover")#only Axl and Pallette

onready var sfx: = $sfx

onready var animatedSprite: AnimatedSprite = $animatedSprite

var player_should_die_to_spikes: bool = true
var should_decay: bool = false
var heal_time: float = 1.0
var heal_timer: float = 0.0
var sfx_timer: float = 0.0
var sfx_time: float = 0.13

var recover: bool = false

func _ready() -> void :
	Event.listen("axl_special_ability", self, "ability_parts")

func ability_parts(ability_name: String):
	if not recover:
		backup_original_values()
	if not CharacterManager.share_axl_buff or not "share_axl_buff" in GameManager.collectibles:
		recover = false
		unset_aura_buff()
		return
	if ability_name == "blastlauncher":
		recover = true
		set_aura_buff()
	else:
		recover = false
		unset_aura_buff()

func _physics_process(delta: float) -> void :
	if recover:
		animatedSprite.show()
		sfx_timer -= delta
		if sfx_timer <= 0:
			sfx_timer = sfx_time
			sfx.play()
		heal_timer += delta
		if heal_timer >= heal_time:
			heal_timer = 0
			player_lifesteal.heal(2)
	else:
		animatedSprite.hide()

func set_aura_buff() -> void :
	player_dashwalljump.deactivate()
	player_dash.deactivate()
	player_dashjump.deactivate()
	player_airdash.deactivate()
	player_lifesteal.should_decay = false
	character.should_die_to_spikes = false
	if not player_hover == null:
		player_hover.deactivate()
	if not player_doublejump == null:
		player_doublejump.deactivate()

func unset_aura_buff() -> void :
	player_dashwalljump.activate()
	player_dash.activate()
	player_dashjump.activate()
	player_airdash.activate()
	player_lifesteal.should_decay = should_decay
	character.should_die_to_spikes = player_should_die_to_spikes
	if not player_hover == null:
		player_hover.activate()
	if not player_doublejump == null:
		player_doublejump.activate()

func backup_original_values() -> void :
	should_decay = player_lifesteal.should_decay
	player_should_die_to_spikes = character.should_die_to_spikes
