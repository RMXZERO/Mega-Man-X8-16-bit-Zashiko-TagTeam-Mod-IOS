extends Node

export  var connect_at_start: = true
export  var character: = "MegaMan X"
export  var _animatedSprite: NodePath
onready var animated_sprite: = get_node(_animatedSprite)
onready var weak = get_parent().get_parent().get_node("Idle")
onready var player = get_parent().get_parent()

func _ready() -> void :
	if connect_at_start:
		connect_talking()

func connect_talking():
		Event.listen("character_talking", self, "talk")

func talk(talking_character):
	if animated_sprite.animation == "idle" or animated_sprite.animation == "talk" or animated_sprite.animation == "weak" or animated_sprite.animation == "weak_talk":
		if talking_character == character:
			if player.is_low_health() or weak.idle_weak:
				if animated_sprite.animation != "weak_talk":
					animated_sprite.play("weak_talk")
			else:
				if animated_sprite.animation != "talk":
					animated_sprite.play("talk")

		else:
			if player.is_low_health() or weak.idle_weak:
				if animated_sprite.animation != "weak":
					animated_sprite.play("weak")
			else:
				if animated_sprite.animation != "idle":
					animated_sprite.play("idle")
