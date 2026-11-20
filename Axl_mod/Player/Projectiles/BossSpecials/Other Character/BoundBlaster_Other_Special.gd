extends Node2D

onready var character: = get_parent().get_parent()

onready var animatedSprite: AnimatedSprite = $animatedSprite

var show_shield: bool = false
var rotation_speed: float = 30.0
var player_spike_invincibility: bool = false
var shield_time: float = 16.0
var shield_timer: float = 0.0
var shield_blink_time: float = 0.0125
var shield_blink_timer: float = 0.0

func _ready() -> void :
	Event.listen("axl_special_ability", self, "ability_parts")

func ability_parts(ability_name: String):
	if not show_shield:
		player_spike_invincibility = character.spike_invincibility
	if not CharacterManager.share_axl_buff or not "share_axl_buff" in GameManager.collectibles:
		show_shield = false
		animatedSprite.hide()
		animatedSprite.animation = "shield_end"
		character.spike_invincibility = player_spike_invincibility
		return
	if ability_name == "boundblaster":
		show_shield = true
		animatedSprite.show()
		animatedSprite.play("shield_loop")
		character.spike_invincibility = true
	else:
		show_shield = false
		animatedSprite.show()
		animatedSprite.play("shield_end")
		character.spike_invincibility = player_spike_invincibility

func _physics_process(delta: float) -> void :
	if show_shield:
		animatedSprite.rotation_degrees += rotation_speed * character.get_facing_direction()
		shield_timer += delta
		handle_shield_blink(delta)

func handle_shield_blink(delta) -> void :
	shield_blink_timer += delta
	shield_blink_time = 0.0125
	if shield_blink_timer >= shield_blink_time:
		shield_blink_timer = 0
		animatedSprite.visible = not animatedSprite.visible

func get_facing_direction():
	return character.get_facing_direction()
