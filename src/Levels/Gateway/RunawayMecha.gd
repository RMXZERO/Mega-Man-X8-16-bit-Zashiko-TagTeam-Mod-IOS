extends Actor
onready var pursuit: Node2D = $Pursuit


func activate() -> void :
	Tools.timer(1.0, "_on_signal", pursuit)

func destroy_ridearmor(body: Node) -> void :
	if body.is_in_group("Props"):
		body.get_parent().void_touch()
