extends Node2D

export var pallette: bool = false
onready var pallette_texture: Texture = preload("res://Axl_mod/WeaponGet/Weaponget_new_pallette.png")
onready var axl_material: Material = preload("res://Axl_mod/Player/Axl_Material_Shader.tres")
onready var pallette_material: Material = preload("res://Axl_mod/Player/Pallette_Material_Shader.tres")
onready var weapon_get_texture: Sprite = $Armor/normal

signal initialize
signal reset
signal start
signal flash
signal weapon_defined(weapon)

func _ready() -> void :
	Tools.timer(0.2, "initialize", self)
	weapon_get_texture.material = axl_material
	CharacterManager.set_axl_colors(weapon_get_texture)
	if pallette:
		weapon_get_texture.texture = pallette_texture
		weapon_get_texture.material = pallette_material
		CharacterManager.set_pallette_colors(weapon_get_texture)

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
