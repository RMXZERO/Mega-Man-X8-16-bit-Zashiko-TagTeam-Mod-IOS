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

onready var ultimte_icon_texture: Texture = preload("res://X_mod/UltimateX/HUD/ultimate_x.png")
onready var ultimte_icon_material: Material = preload("res://X_mod/UltimateX/Sprites/x_ultimate_material.tres")
onready var x_icon_texture: Texture = preload("res://src/Options/base_X.png")
onready var x_x8_icon_texture: Texture = preload("res://X_mod/X8/HUD/base_X_X8.png")
onready var normal_icon_material: Material = preload("res://src/Effects/Materials/Player_Material_Shader.tres")
onready var infinite_icon_texture: Texture = preload("res://X_mod/InfiniteX/HUD/infinite_x_icon.png")
onready var _live_icon: TextureRect = $"../lives_icon"
onready var normal_life_texture: Texture = preload("res://src/Options/lives.png")
onready var ultimate_life_texture: Texture = preload("res://X_mod/UltimateX/HUD/life.png")
onready var main_alia_icon: TextureRect = get_parent().get_node_or_null("Alia_icon")

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
	Event.listen("changed_weapon", self, "update_colors")
	Event.listen("collected_zero_weapon", self, "show_parts")
	show_parts()

func show_parts() -> void :
	for part in armor_parts:
		if GameManager.is_player_in_scene():
			part.visible = part.name in GameManager.player.current_armor
	if CharacterManager.ultimate_x_armor or CharacterManager.hide_x_armor or CharacterManager.infinite_x_activated:
		for part in armor_parts:
			part.visible = false
	switch_icon()
	update_colors()

func switch_icon() -> void :
	if _live_icon:
		_live_icon.texture = normal_life_texture
	if CharacterManager.use_old_sprite:
		texture = x_icon_texture
		material = normal_icon_material
	elif not CharacterManager.use_old_sprite:
		texture = x_x8_icon_texture
		material = normal_icon_material
	if CharacterManager.ultimate_x_armor and not CharacterManager.infinite_x_activated and not CharacterManager.hide_x_armor:
		texture = ultimte_icon_texture
		material = ultimte_icon_material
		if _live_icon:
			_live_icon.texture = ultimate_life_texture
	if CharacterManager.infinite_x_activated and CharacterManager.use_old_sprite:
		texture = infinite_icon_texture
		material = null

func update_colors(_n = null) -> void :
	if GameManager.is_player_in_scene():
		if visible:
			material = GameManager.player.animatedSprite.material.duplicate()
			if CharacterManager.ultimate_x_armor and not CharacterManager.infinite_x_activated and not CharacterManager.hide_x_armor:
				var normal_material = GameManager.player.get_node_or_null("animatedSprite").get_node_or_null("ultimate_armor")
				if normal_material:
					material = normal_material.material.duplicate()
			material.set_shader_param("Flash", 0)
			material.set_shader_param("Charge", 0)
			material.set_shader_param("Alpha", 1)
			_live_icon.material = material
		else:
			main_alia_icon.material = GameManager.player.animatedSprite.material.duplicate()
			main_alia_icon.material.set_shader_param("Flash", 0)
			main_alia_icon.material.set_shader_param("Charge", 0)
			main_alia_icon.material.set_shader_param("Alpha", 1)
