extends GenericProjectile
var exploded: = false
onready var vanish: AudioStreamPlayer2D = $vanish
onready var fire_1: Particles2D = $animatedSprite/fire1
onready var fire_2: Particles2D = $animatedSprite/fire2
onready var fire_3: Particles2D = $animatedSprite/fire3
onready var ceiling_check: Array = [$platform / wallCheck_up, $platform / wallCheck_up2]

const bypass_shield: = true
const continuous_damage := false
const destroyer := false

func _ready():
	pass

func set_direction(new_direction):
	facing_direction = new_direction
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	animatedSprite.scale.x = new_direction
	
func _Update(_delta: float) -> void :
	if not exploded and is_on_ceiling():
		explode()
	if not exploded:
		destroy_if_low_ceiling()

func destroy_if_low_ceiling() -> void :
	for check in ceiling_check:
		if check.is_colliding():
			#destroy()
			explode()

func _OnHit(_target_remaining_HP) -> void :
	pass

func deflect(_var) -> void :
	pass

func explode() -> void :
	fire_1.emitting = false
	fire_2.emitting = false
	fire_3.emitting = false
	animatedSprite.play("enkoujinwaveexplode")
	exploded = true
	disable_damage()
	Tools.timer(1, "destroy", self)
	vanish.play_rp()
	set_vertical_speed(0)
