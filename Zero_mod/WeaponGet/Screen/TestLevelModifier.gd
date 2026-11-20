extends Node
onready var spike_row: Node2D = $"../Objects/SpikeRow"
onready var servbot: KinematicBody2D = $"../Objects/Servbot"
onready var servbot_2: KinematicBody2D = $"../Objects/Servbot2"
onready var servbot_3: KinematicBody2D = $"../Objects/Servbot3"

onready var drone_2: KinematicBody2D = $"../Objects/Drone2"
onready var wall: TileMap = $"../Scenery/Collision"
onready var wall2: TileMap = $"../Scenery/Collision2"

func _on_WeaponGetScreen_weapon_defined(weapon: WeaponResource) -> void :
	if weapon.collectible == "trilobyte_weapon":
		call_deferred("delete_spikes")
		call_deferred("delete_servbots")
		CharacterManager.rekkyoudan_active = true
		CharacterManager.layer_rekkyoudan_active = true
	if weapon.collectible == "antonion_weapon":
		call_deferred("delete_spikes")
	if weapon.collectible == "rooster_weapon":
		call_deferred("delete_spikes")
		call_deferred("delete_servbots")
		call_deferred("move_wall")
	if weapon.collectible == "manowar_weapon":
		call_deferred("delete_spikes")
		call_deferred("delete_servbots")
	if weapon.collectible == "panda_weapon":
		call_deferred("delete_servbots")
	if weapon.collectible == "mantis_weapon":
		call_deferred("delete_drones")
	if weapon.collectible == "sunflower_weapon":
		call_deferred("delete_drones")
		call_deferred("delete_spikes")
	if weapon.collectible == "yeti_weapon":
		call_deferred("delete_drones")
		call_deferred("delete_spikes")
	printdebug(weapon)

func printdebug(weapon: WeaponResource) -> void :
	if weapon.collectible == "trilobyte_weapon":
		print("trilobyte_weapon")
	elif weapon.collectible == "antonion_weapon":
		print("antonion_weapon")
	elif weapon.collectible == "rooster_weapon":
		print("rooster_weapon")
	elif weapon.collectible == "manowar_weapon":
		print("manowar_weapon")
	elif weapon.collectible == "panda_weapon":
		print("panda_weapon")
	elif weapon.collectible == "mantis_weapon":
		print("mantis_weapon")
	elif weapon.collectible == "sunflower_weapon":
		print("sunflower_weapon")
	elif weapon.collectible == "yeti_weapon":
		print("yeti_weapon")
	else:
		print("no_weapon")

func delete_spikes():
	spike_row.queue_free()
	
func delete_servbots():
	servbot.queue_free()
	servbot_2.queue_free()
	servbot_3.queue_free()

func delete_drones():
	drone_2.queue_free()

func move_wall():
	wall.position.x -= 48
	wall2.position.y += 32
	wall2.position.x -= 48


