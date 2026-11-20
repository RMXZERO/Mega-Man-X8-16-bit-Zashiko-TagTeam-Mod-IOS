extends TextureRect
onready var pause: CanvasLayer = $"../../.."

onready var hermes_head: TextureRect = $hermes_head
onready var hermes_body: TextureRect = $hermes_body
onready var hermes_arms: TextureRect = $hermes_arms
onready var hermes_legs: TextureRect = $hermes_legs
onready var icarus_head: TextureRect = $icarus_head
onready var icarus_body: TextureRect = $icarus_body
onready var icarus_arms: TextureRect = $icarus_arms
onready var icarus_legs: TextureRect = $icarus_legs

onready var axl_icon: TextureRect = $Axl_icon
onready var zero_icon: TextureRect = $Zero_icon
onready var alia_icon: TextureRect = $Alia_icon
onready var layer_icon: TextureRect = $Layer_icon
onready var pallette_icon: TextureRect = $Pallette_icon

onready var main_x_icon: TextureRect = get_parent().get_node_or_null("X_icon")
onready var main_axl_icon: TextureRect = get_parent().get_node_or_null("Axl_icon")
onready var main_zero_icon: TextureRect = get_parent().get_node_or_null("Zero_icon")
onready var main_alia_icon: TextureRect = get_parent().get_node_or_null("Alia_icon")
onready var main_layer_icon: TextureRect = get_parent().get_node_or_null("Layer_icon")
onready var main_pallette_icon: TextureRect = get_parent().get_node_or_null("Pallette_icon")

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
	Tools.timer(0.1,"connect_inactive_icon",self)

func connect_inactive_icon() -> void :
	if GameManager.inactive_player and is_instance_valid(GameManager.inactive_player) or CharacterManager.team.size() > 1:
		visible = true
		pause.connect("pause_starting", self, "check_inactive_player_name")
	else:
		visible = false

func check_inactive_player_name() -> void :
	reset_part_icon()
	if GameManager.inactive_player and is_instance_valid(GameManager.inactive_player):
		if GameManager.inactive_player.name == "X":
			show_x_armor_parts()
			texture = main_x_icon.texture
			material = main_x_icon.material
		elif GameManager.inactive_player.name == "Zero":
			zero_icon.visible = true
			zero_icon.texture = main_zero_icon.texture
		elif GameManager.inactive_player.name == "Axl":
			axl_icon.visible = true
			axl_icon.texture = main_axl_icon.texture
		elif GameManager.inactive_player.name == "Alia":
			alia_icon.visible = true
			alia_icon.texture = main_alia_icon.texture
		elif GameManager.inactive_player.name == "Layer":
			layer_icon.visible = true
			layer_icon.texture = main_layer_icon.texture
		elif GameManager.inactive_player.name == "Pallette":
			pallette_icon.visible = true
			pallette_icon.texture = main_pallette_icon.texture

func reset_part_icon() -> void :
	zero_icon.visible = false
	axl_icon.visible = false
	alia_icon.visible = false
	layer_icon.visible = false
	pallette_icon.visible = false
	self_modulate = Color(1, 1, 1, 0)
	for part in armor_parts:
		part.visible = false

func show_x_armor_parts() -> void :
	self_modulate = Color(1, 1, 1, 1)
	for part in armor_parts:
		if GameManager.is_player_in_scene():
			part.visible = part.name in GameManager.inactive_player.current_armor
	if CharacterManager.ultimate_x_armor or CharacterManager.hide_x_armor or CharacterManager.infinite_x_activated:
		for part in armor_parts:
			part.visible = false

