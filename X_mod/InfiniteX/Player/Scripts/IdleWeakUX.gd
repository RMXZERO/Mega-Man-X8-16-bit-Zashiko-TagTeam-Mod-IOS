extends Idle

onready var animatedSprite = get_parent().get_node("animatedSprite")
var idle_weak: bool = false

func _ready() -> void :
	._ready()

func _on_animatedSprite_animation_finished() -> void :
	if executing:
		if not is_shooting() and is_playing_recover() or not is_shooting() and is_playing_shot_recover():
			if character.is_low_health():
				character.play_animation("weak")
				idle_weak = true
			elif idle_weak:
				character.play_animation("weak")
			else:
				character.play_animation("idle")

func recover() -> void :
	if executing:
		if character.is_low_health():
			character.play_animation("shot_recover")
			character.animatedSprite.set_frame(0)
		else:
			character.play_animation("recover")
			character.animatedSprite.set_frame(0)

func is_playing_recover() -> bool:
	return character.get_animation() == "recover"

func is_playing_shot_recover() -> bool:
	return character.get_animation() == "shot_recover"

func is_shooting() -> bool:
	return character.get_animation_layer().resource_name == "pointing_cannon"
