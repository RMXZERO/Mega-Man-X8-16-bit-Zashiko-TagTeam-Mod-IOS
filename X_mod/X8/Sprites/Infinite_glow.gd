extends Node2D

onready var tween: SceneTreeTween

onready var character = get_parent()
onready var playerSprite = character.get_node("animatedSprite")

export var OriginalCrystalColor1: Color = Color("#ffffd2")
export var OriginalCrystalColor2: Color = Color("#ffff00")
export var OriginalCrystalColor3: Color = Color("#ffe600")
export var OriginalCrystalColor4: Color = Color("#e1c800")
export var OriginalHandColor1: Color = Color("#00e6e6")
export var OriginalHandColor2: Color = Color("#00c8c8")
export var OriginalHandColor3: Color = Color("#009696")
export var OriginalHandColor4: Color = Color("#007878")

var CrystalColor1: Color
var CrystalColor2: Color
var CrystalColor3: Color
var HandColor1: Color
var HandColor2: Color
var HandColor3: Color

var NormalCrystalColor1: Color
var NormalCrystalColor2: Color
var NormalCrystalColor3: Color
var NormalHandColor1: Color
var NormalHandColor2: Color
var NormalHandColor3: Color

var save_color: bool = false

func _ready() -> void :
	save_original_colors()

func _process(_delta: float) -> void :
	if CharacterManager.infinite_x_glow and not CharacterManager.weaponget and CharacterManager.infinite_x_activated:
		if save_color:
			cycle_colors()
			handle_infinite_glow(playerSprite)
	else:
		if save_color:
			handle_normal_color(playerSprite)
		if tween and tween.is_valid():
			tween.kill()

func save_original_colors() -> void :
	if not save_color:
		if playerSprite.material is ShaderMaterial:
			NormalCrystalColor1 = playerSprite.material.get_shader_param("R_CrystalColor1")
			NormalCrystalColor2 = playerSprite.material.get_shader_param("R_CrystalColor2")
			NormalCrystalColor3 = playerSprite.material.get_shader_param("R_CrystalColor3")
			NormalHandColor1 = playerSprite.material.get_shader_param("R_InfiniteHand1")
			NormalHandColor2 = playerSprite.material.get_shader_param("R_InfiniteHand2")
			NormalHandColor3 = playerSprite.material.get_shader_param("R_InfiniteHand3")
			save_color = true

func reset_material(material: ShaderMaterial) -> void :
	if material != null:
		var new_material = ShaderMaterial.new()
		new_material.shader = material.shader
		material = new_material

func handle_normal_color(node) -> void :
	reset_material(node.material)
	if node != null:
		node.material.set_shader_param("R_CrystalColor1", Color(NormalCrystalColor1))
		node.material.set_shader_param("R_CrystalColor2", Color(NormalCrystalColor2))
		node.material.set_shader_param("R_CrystalColor3", Color(NormalCrystalColor3))
		node.material.set_shader_param("R_InfiniteHand1", Color(NormalHandColor1))
		node.material.set_shader_param("R_InfiniteHand2", Color(NormalHandColor2))
		node.material.set_shader_param("R_InfiniteHand3", Color(NormalHandColor3))

func handle_infinite_glow(node) -> void :
	reset_material(node.material)
	if node != null:
		node.material.set_shader_param("R_CrystalColor1", Color(CrystalColor1))
		node.material.set_shader_param("R_CrystalColor2", Color(CrystalColor2))
		node.material.set_shader_param("R_CrystalColor3", Color(CrystalColor3))
		node.material.set_shader_param("R_InfiniteHand1", Color(HandColor1))
		node.material.set_shader_param("R_InfiniteHand2", Color(HandColor2))
		node.material.set_shader_param("R_InfiniteHand3", Color(HandColor3))

const color_cycle_duration: = 0.15
func cycle_colors() -> void :
	if not tween or not tween.is_valid():
		tween = create_tween().set_loops()
		tween.tween_property(self, "CrystalColor1", OriginalCrystalColor1, color_cycle_duration)
		tween.set_parallel().tween_property(self, "CrystalColor2", OriginalCrystalColor2, color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "CrystalColor3", OriginalCrystalColor3, color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "HandColor1", OriginalHandColor1, color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "HandColor2", OriginalHandColor2, color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "HandColor3", OriginalHandColor3, color_cycle_duration * 2)
		
		tween.chain().tween_property(self, "CrystalColor1", OriginalCrystalColor2, color_cycle_duration)
		tween.set_parallel().tween_property(self, "CrystalColor2", OriginalCrystalColor3, color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "CrystalColor3", OriginalCrystalColor4, color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "HandColor1", OriginalHandColor2, color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "HandColor2", OriginalHandColor3, color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "HandColor3", OriginalHandColor4, color_cycle_duration * 2)

