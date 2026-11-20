extends Node

export var active := true
var one_time: bool = false

func _on_RideArmor_land() -> void:
	if active:
		Event.emit_signal("screenshake",0.8)

func death() -> void:
	if active and not one_time:
		one_time = true
		Event.emit_signal("screenshake",0.8)
