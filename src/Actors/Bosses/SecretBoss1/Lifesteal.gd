extends Node
onready var character: KinematicBody2D = $".."

export  var recover_health: = 10

func _ready() -> void:
	Event.listen("damage", self, "on_damage_player")
	Event.listen("mu_barrier_break", self, "no_damage_player")
	pass

func activate():
	GameManager.player.connect("received_damage",self,"on_damage_player")
	pass

func on_damage_player():
	if character.has_health() and character.current_health < character.max_health:
		character.recover_health(recover_health)
	pass

func no_damage_player():
	if character.has_health() and character.current_health < character.max_health:
		character.recover_health( - recover_health)
	pass

func _on_Intro_executed() -> void:
	activate()
	pass # Replace with function body.
