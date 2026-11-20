extends Panda

onready var dmg_sfx: AudioStreamPlayer = $damage
onready var nova_strike_back = $animatedSprite/animatedSprite
onready var sprite = get_node("animatedSprite")
onready var afterimages = get_node("animatedSprite").get_node("afterImages")
onready var afterimages2 = get_node("animatedSprite").get_node("afterImages2")

var only_x: bool = false
var only_zero: bool = false
var only_axl: bool = false

func _ready() -> void :
	Event.listen("show_life_steal_bar", self, "afterimages")
	nova_strike_back.hide()
	only_x = false
	only_zero = false
	only_axl = false
	set_x_boss_normal_colors(sprite)
	if CharacterManager.player_character == "X":
		only_x = true
	elif CharacterManager.player_character == "Axl":
		only_axl = true
	elif CharacterManager.player_character == "Zero":
		only_zero = true
	else:
		only_x = true
	if Input.is_action_pressed("select_special"):
		CharacterManager.nightshade_zero_armor = true

func afterimages() -> void :
	set_x_boss_normal_colors(sprite)
	afterimages.active = true
	afterimages.activate()
	nightshade_zero_armor()

func nightshade_zero_armor() -> void :
	if CharacterManager.nightshade_zero_armor:
		afterimages2.active = true
		afterimages2.activate()

func _process(_delta: float) -> void :
	._process(_delta)

func reset_material(material: ShaderMaterial) -> void :
	if material != null:
		var new_material = ShaderMaterial.new()
		new_material.shader = material.shader
		material = new_material

func set_x_boss_no_armor_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		node.material.set_shader_param("R_MainColor1", Color("#0080f8"))
		node.material.set_shader_param("R_MainColor2", Color("#0040f0"))
		node.material.set_shader_param("R_MainColor3", Color("#203080"))
		node.material.set_shader_param("R_MainColor4", Color("#78d8f0"))
		node.material.set_shader_param("R_MainColor5", Color("#50a0f0"))
		node.material.set_shader_param("R_MainColor6", Color("#1858b0"))

func set_x_boss_normal_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		node.material.set_shader_param("R_MainColor1", Color("#4d547d"))
		node.material.set_shader_param("R_MainColor2", Color("#29345b"))
		node.material.set_shader_param("R_MainColor3", Color("#132247"))
	
		node.material.set_shader_param("R_MainColor4", Color("#687ccc"))
		node.material.set_shader_param("R_MainColor5", Color("#506090"))
		node.material.set_shader_param("R_MainColor6", Color("#2c3956"))
	
		node.material.set_shader_param("R_CrystalColor1", Color("#d77be6"))
		node.material.set_shader_param("R_CrystalColor2", Color("#8d2bba"))
		node.material.set_shader_param("R_CrystalColor3", Color("#60008d"))
		node.material.set_shader_param("R_CrystalColor4", Color("#ffb4ff"))
	
		node.material.set_shader_param("R_ArmorColor1", Color("#e8e040"))
		node.material.set_shader_param("R_ArmorColor2", Color("#f19946"))
		node.material.set_shader_param("R_ArmorColor3", Color("#ab5044"))

func set_x_boss_soul_body_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		node.material.set_shader_param("R_ArmorColor1", Color("#dca574"))
		node.material.set_shader_param("R_ArmorColor2", Color("#b56b21"))
		node.material.set_shader_param("R_ArmorColor3", Color("#6e3b21"))
		
		node.material.set_shader_param("R_MainColor4", Color("#f5eed1"))
		node.material.set_shader_param("R_MainColor5", Color("#debb79"))
		node.material.set_shader_param("R_MainColor6", Color("#9e7b54"))

func set_x_boss_frost_tower_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		node.material.set_shader_param("R_ArmorColor1", Color("#f0f0f0"))
		node.material.set_shader_param("R_ArmorColor2", Color("#97a8bf"))
		node.material.set_shader_param("R_ArmorColor3", Color("#56648a"))
		
		node.material.set_shader_param("R_MainColor4", Color("#b1dce2"))
		node.material.set_shader_param("R_MainColor5", Color("#7db0e3"))
		node.material.set_shader_param("R_MainColor6", Color("#3b4781"))

func set_x_boss_double_cyclone_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		node.material.set_shader_param("R_ArmorColor1", Color("#62d862"))
		node.material.set_shader_param("R_ArmorColor2", Color("#3e9e4f"))
		node.material.set_shader_param("R_ArmorColor3", Color("#365e5b"))
		
		node.material.set_shader_param("R_MainColor4", Color("#e1eaa9"))
		node.material.set_shader_param("R_MainColor5", Color("#91a852"))
		node.material.set_shader_param("R_MainColor6", Color("#517044"))

func set_x_boss_ray_arrow_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		node.material.set_shader_param("R_ArmorColor1", Color("#fce172"))
		node.material.set_shader_param("R_ArmorColor2", Color("#e8a830"))
		node.material.set_shader_param("R_ArmorColor3", Color("#a86820"))
		
		node.material.set_shader_param("R_MainColor4", Color("#fcfce8"))
		node.material.set_shader_param("R_MainColor5", Color("#97be97"))
		node.material.set_shader_param("R_MainColor6", Color("#5d7962"))
