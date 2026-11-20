extends Control
onready var hermes_head: X8OptionButton = $ArmorParts / HermesParts / hermes_head
onready var hermes_body: X8OptionButton = $ArmorParts / HermesParts / hermes_body
onready var hermes_arms: X8OptionButton = $ArmorParts / HermesParts / hermes_arms
onready var hermes_legs: X8OptionButton = $ArmorParts / HermesParts / hermes_legs
onready var icarus_head: X8OptionButton = $ArmorParts / IcarusParts / icarus_head
onready var icarus_body: X8OptionButton = $ArmorParts / IcarusParts / icarus_body
onready var icarus_arms: X8OptionButton = $ArmorParts / IcarusParts / icarus_arms
onready var icarus_legs: X8OptionButton = $ArmorParts / IcarusParts / icarus_legs


onready var pause: CanvasLayer = $"../.."


onready var armor_parts = [
	hermes_head, 
	hermes_body, 
	hermes_arms, 
	hermes_legs, 
	icarus_head, 
	icarus_body, 
	icarus_arms, 
	icarus_legs
]

func _ready() -> void :
	pause.connect("pause_starting", self, "show_parts")
	Event.connect("collected_zero_weapon", self, "show_parts")

func show_parts() -> void :
	for part in armor_parts:
		part.modulate = Color.dimgray
		part.visible = part.name in GameManager.collectibles
		
		if GameManager.is_player_in_scene():
			if part.name in GameManager.player.current_armor:
				part.modulate = Color.white
	
