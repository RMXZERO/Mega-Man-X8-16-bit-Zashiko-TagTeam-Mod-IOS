extends BossDeath

func _Setup() -> void:
	._Setup()
	Event.emit_signal("enemy_kill", "copysigma")
