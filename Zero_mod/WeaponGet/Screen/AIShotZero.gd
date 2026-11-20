extends PrimaryShot

onready var animatedSprite = character.get_node("animatedSprite")
onready var saber_jump: Node2D = $"../SaberJump"

func _ready() -> void :
	if active:
		Event.listen("customzerocolor", self, "reload_color")
		Event.listen("character_switch", self, "reload_color")
		Event.listen("character_switch_end", self, "reload_color")
		unlock_ability("collectible")
		unlock_weapon("collectible")
		reload_color()
		afterImages_color()

func reload_color() -> void :
	if CharacterManager.player_character == "Zero":
		if is_instance_valid(GameManager.player):
			var zero = GameManager.player
			CharacterManager.set_zeroX8_colors(zero.animatedSprite)
			CharacterManager.set_saberX8_colors(zero.animatedSprite)
			afterImages_color()
			upgraded = true

func afterImages_color() -> void :
	var material_color = character.get_material()
	if material_color is ShaderMaterial:
		$"../animatedSprite/afterImages".initial_color = material_color.get_shader_param("R_AfterimagesColor")

func fire(_weapon):
	pass

func get_action_just_pressed(_element) -> bool:
	if just_pressed:
		just_pressed = false
		return true
	return false
func get_action_pressed(_element) -> bool:
	return pressed
func get_action_just_released(_element) -> bool:
	return just_released

func set_current_weapon(zeroability):
	current_weapon = zeroability
	update_character_palette()
	Log("Changed Weapon to " + current_weapon.name)
	Event.emit_signal("changed_weapon", current_weapon)
	next_shot_ready = false

var just_pressed: = false
var just_released: = false
var pressed: = false

func _input(_event: InputEvent) -> void :
	pass

func unlock_ability(collectible: String) -> void :
	for child in get_children():
		if child is BossAbilityZero:
			if child.should_unlock(collectible):
				child.active = true



