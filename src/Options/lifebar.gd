extends NinePatchRect
onready var current: TextureProgress = $current

onready var original_pos = Vector2(rect_position.x, rect_size.x)
onready var name_text: Label = $current/Text
var original_max_health = CharacterManager.starting_max_health
var complete_max_health
export var is_inactive_player: bool = false

func _ready() -> void :
	complete_max_health = original_max_health + (CharacterManager.heart_tank_buff_amt * 12)
	Tools.timer(0.1,"connect_inactive_bar",self)

func connect_inactive_bar() -> void :
	if GameManager.inactive_player and is_instance_valid(GameManager.inactive_player) or CharacterManager.team.size() > 1:
		if is_inactive_player:
			visible = true
		if not is_inactive_player:
			rect_position.y -= 3

func _process(_delta: float) -> void :
	if visible and GameManager.player and is_instance_valid(GameManager.player) and not is_inactive_player:
		current.value = complete_max_health * inverse_lerp(0, complete_max_health, GameManager.player.current_health)
		name_text.text = String(GameManager.player.name)
		var s = GameManager.player.max_health - original_max_health
		if s >= 0 and rect_position.x != original_pos.x - s:
			rect_position.x = original_pos.x - s
			rect_size.x = original_pos.y + s * 2
		
	if visible and GameManager.inactive_player and is_instance_valid(GameManager.inactive_player) and is_inactive_player:
		current.value = complete_max_health * inverse_lerp(0, complete_max_health, GameManager.inactive_player.current_health)
		name_text.text = String(GameManager.inactive_player.name)
		var s = GameManager.inactive_player.max_health - original_max_health
		if s >= 0 and rect_position.x != original_pos.x - s:
			rect_position.x = original_pos.x - s
			rect_size.x = original_pos.y + s * 2
