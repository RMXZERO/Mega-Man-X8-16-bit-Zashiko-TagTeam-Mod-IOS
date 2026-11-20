extends RigidBody2D

func hit(boss) -> void:
	boss.damage(25,self)
	Event.emit_signal("screenshake",2.0)
