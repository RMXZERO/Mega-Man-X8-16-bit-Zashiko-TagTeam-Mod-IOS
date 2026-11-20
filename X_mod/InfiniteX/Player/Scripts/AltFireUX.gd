extends Shot
onready var buster: Node2D = $Buster
onready var icarus_buster: Node2D = get_node_or_null("Icarus Buster")
onready var weak = get_parent().get_node("Idle")

func switch_to_icarus():
	buster.active = false
	if icarus_buster != null:
		icarus_buster.active = true
		set_current_weapon(icarus_buster)
	
func switch_to_hermes():
	buster.active = true
	
	if icarus_buster != null:
		icarus_buster.active = false
		set_current_weapon(buster)

func restart_animation() -> void :
	if character.get_animation() == "recover":
		if character.is_low_health() or weak.idle_weak:
			character.animatedSprite.play("shot_recover")
			character.animatedSprite.set_frame(1)
		character.animatedSprite.set_frame(1)
