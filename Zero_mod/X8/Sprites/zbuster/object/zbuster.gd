extends SimplePlayerProjectile
var tracking: bool = false

var nightmare: bool = false
const bypass_shield: = true

func _ready() -> void :
	if nightmare:
		set_vertical_speed((0 + rand_range( - 50, 50))* get_facing_direction())

func _Update(delta: float) -> void :
	._Update(delta)
	set_horizontal_speed(420 * get_facing_direction())
	set_rotation(Vector2(get_horizontal_speed(), 0).angle())
	if animatedSprite.frame >= 93:
		animatedSprite.frame = 3

func _OnHit(_target_remaining_HP) -> void :
	pass

func deflect(_var) -> void :
	pass

func set_direction(new_direction) -> void :
	Log("Seting direction: " + str(new_direction))
	facing_direction = new_direction

