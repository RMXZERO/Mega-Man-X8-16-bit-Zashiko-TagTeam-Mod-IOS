extends Node2D

var only_x: bool = false
var only_zero: bool = false
var only_axl: bool = false

func _ready() -> void :
	$animatedSprite.visible = false
	$explosionParticles.visible = false
	$animatedSprite.playing = true
	Tools.timer(0.4, "damage_on", self)

func damage_on() -> void :
	z_index += 1
	$animatedSprite.visible = true
	$explosionParticles.visible = true
	$shot.play()
	$ShotHitbox.activate()
	Event.emit_signal("screenshake", 1)
	Tools.timer(0.05, "queue_free", self)

func _process(delta: float) -> void :
	pass
