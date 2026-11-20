extends Panda

onready var sfx_recover: AudioStreamPlayer = get_node("heal_sound")
onready var afterimages = get_node("animatedSprite").get_node("afterImages")
onready var afterimages2 = get_node("animatedSprite").get_node("afterImages2")
onready var sprite = get_node("animatedSprite")
onready var effect_sprite = get_node("animatedSprite").get_node("effectSprite")
var only_x: bool = false
var only_zero: bool = false
var only_axl: bool = false

func _ready() -> void :
	CharacterManager.set_zeroX8_normal_colors(sprite)
	CharacterManager.set_saberX8_green(sprite)
	
	only_x = false
	only_zero = false
	only_axl = false
	
	if CharacterManager.player_character == "X":
		CharacterManager.set_zeroX8_normal_colors(sprite)
		CharacterManager.set_saberX8_green(sprite)
		only_x = true
	elif CharacterManager.player_character == "Zero":
		CharacterManager.set_omega_zeroX8_colors(sprite)
		CharacterManager.set_saber_omega_pink(sprite)
		only_zero = true
	elif CharacterManager.player_character == "Axl":
		CharacterManager.set_omega_zeroX8_colors(sprite)
		CharacterManager.set_saber_omega_pink(sprite)
		only_axl = true
	else:
		CharacterManager.set_omega_zeroX8_colors(sprite)
		CharacterManager.set_saber_omega_pink(sprite)
		only_zero = true
	
	if Input.is_action_pressed("select_special"):
		CharacterManager.nightshade_zero_armor = true
	
	nightshade_zero_armor()

func _process(_delta: float) -> void:
	._process(_delta)

func dash_afterimages() -> void :
	afterimages.active = true
	afterimages.activate()

func flash_afterimages() -> void :
	afterimages2.active = true
	afterimages2.extra_scale = 1.0
	afterimages2.activate()
	set_aura_colors(sprite)
	yield(get_tree().create_timer(0.5), "timeout")
	afterimages2.extra_scale = 1.1
	yield(get_tree().create_timer(0.5), "timeout")
	afterimages2.extra_scale = 1.2
	yield(get_tree().create_timer(1.0), "timeout")
	afterimages2.extra_scale = 1.3
	yield(get_tree().create_timer(1.0), "timeout")
	afterimages2.extra_scale = 1.4
	yield(get_tree().create_timer(1.0), "timeout")
	afterimages2.extra_scale = 1.5

func reset_material(material: ShaderMaterial) -> void :
	if material != null:
		var new_material = ShaderMaterial.new()
		new_material.shader = material.shader
		material = new_material

func set_aura_colors(node) -> void :
	reset_material(node.material)
	if node != null:
		node.material.set_shader_param("R_AuraColor", Color("#FFFFFF"))

func nightshade_zero_armor() -> void :
	if CharacterManager.nightshade_zero_armor and only_x:
		var material = get_node("animatedSprite").get_material()
		afterimages2.custom_omega_aura = true
		afterimages2.initial_color = material.get_shader_param("R_AuraColor")
		afterimages2.final_color = material.get_shader_param("R_AuraColor")
		#afterimages2.active = true
		#afterimages2.activate()
		effect_sprite.z_index = -5

func crash_beam_recover_health():
	crash_beam_recover()
	Tools.timer(0.1, "crash_beam_recover", self)
	Tools.timer(0.2, "crash_beam_recover", self)
	Tools.timer(0.3, "crash_beam_recover", self)
	Tools.timer(0.4, "crash_beam_recover", self)
	Tools.timer(0.5, "crash_beam_recover", self)
	Tools.timer(0.6, "crash_beam_recover", self)
	Tools.timer(0.7, "crash_beam_recover", self)
	Tools.timer(0.8, "crash_beam_recover", self)
	Tools.timer(0.9, "crash_beam_recover", self)
	Tools.timer(1.0, "crash_beam_recover", self)
	Tools.timer(1.1, "crash_beam_recover", self)

func crash_beam_recover():
	if sprite.animation == "damage" or sprite.animation == "death":
		return
	if has_health():
		if current_health < max_health:
			sfx_recover.stop()
			sfx_recover.play()
			recover_health(max_health/64/3)
