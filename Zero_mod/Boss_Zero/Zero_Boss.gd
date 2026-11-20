extends Panda

onready var dmg_sfx: AudioStreamPlayer = $damage
onready var afterimages = get_node("animatedSprite").get_node("afterImages")
onready var afterimages2 = get_node("animatedSprite").get_node("afterImages2")
onready var sprite = get_node("animatedSprite")
onready var effect_sprite = get_node("animatedSprite").get_node("effectSprite")
var only_x: bool = false
var only_zero: bool = false
var only_axl: bool = false

func _ready() -> void :
	Event.connect("player_death", self, "false_all")
	CharacterManager.set_zeroX8_normal_colors(sprite)
	CharacterManager.set_saberX8_green(sprite)
	afterimages.active = true
	afterimages.activate()
	
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
		effect_sprite.self_modulate = Color(1, 1, 1, 0)
		afterimages2.active = true
		afterimages2.activate()
	elif CharacterManager.player_character == "Axl":
		CharacterManager.set_new_betazero_fake_colors(sprite)
		CharacterManager.set_saberX8_red(sprite)
		only_axl = true
	else:
		CharacterManager.set_zeroX8_normal_colors(sprite)
		CharacterManager.set_saberX8_green(sprite)
		only_x = true
	
	if Input.is_action_pressed("select_special"):
		CharacterManager.nightshade_zero_armor = true
	
	nightshade_zero_armor()

func false_all() -> void :
	CharacterManager.nightshade_zero_armor = false

func nightshade_zero_armor() -> void :
	if CharacterManager.nightshade_zero_armor and not only_zero:
		var material = get_node("animatedSprite").get_material()
		afterimages2.custom_omega_aura = true
		afterimages2.initial_color = material.get_shader_param("R_AuraColor")
		afterimages2.final_color = material.get_shader_param("R_AuraColor")
		afterimages2.active = true
		afterimages2.activate()
		effect_sprite.z_index = -5

func _on_DamageReflector_shield_broken() -> void :
	if not is_executing("Desperation"):
		damage.invulnerability_time = damage.weakness_invulnerability_time
		damage.emit_signal("charged_weakness_hit", - get_facing_direction())
		damage.max_flash_time = damage.invulnerability_time
		reduce_health(10)
		dmg_sfx.play()
