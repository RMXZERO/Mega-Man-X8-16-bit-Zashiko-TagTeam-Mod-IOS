extends Node2D

export var layer: bool = false
onready var layer_texture: Texture = preload("res://Zero_mod/WeaponGet/WeaponGetSprite/Weaponget_layer.png")
onready var zero_material: Material = preload("res://Zero_mod/X8/Sprites/ZeroX8_Material_Shader.tres")
onready var layer_material: Material = preload("res://Zero_mod/X8/LayerSprites/Layer_Material_Shader.tres")
onready var weapon_get_texture: Sprite = $Armor/normal

signal initialize
signal reset
signal start
signal flash
signal weapon_defined(weapon)

func _ready() -> void :
	Tools.timer(0.2, "initialize", self)
	weapon_get_texture.material = zero_material
	CharacterManager.set_zeroX8_colors(weapon_get_texture)
	if layer:
		weapon_get_texture.texture = layer_texture
		weapon_get_texture.material = layer_material
		CharacterManager.set_layer_colors(weapon_get_texture)

func initialize():
	emit_signal("initialize")
	reset()
	Tools.timer(6.5, "start", self, null, true)
	Tools.timer(8.2, "flash", self, null, true)
	

func reset() -> void :
	emit_signal("reset")

func start() -> void :
	emit_signal("start")

func flash() -> void :
	emit_signal("flash")
	GameManager.pause("weapon_get")


func _on_Armor_defined_weapon(weapon) -> void :
	emit_signal("weapon_defined", weapon)
