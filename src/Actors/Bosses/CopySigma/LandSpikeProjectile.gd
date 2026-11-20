extends GenericProjectile
onready var vanish: AudioStreamPlayer2D = $vanish
export  var mini_projectile: PackedScene
var exploded: = false
onready var fire_1: Particles2D = $animatedSprite/fire1
onready var fire_2: Particles2D = $animatedSprite/fire2
onready var fire_3: Particles2D = $animatedSprite/fire3

onready var animatedSprite_zero = $animatedSprite_zero
onready var fire_zero_1: Particles2D = $animatedSprite_zero/fire1
onready var fire_zero_2: Particles2D = $animatedSprite_zero/fire2
onready var fire_zero_3: Particles2D = $animatedSprite_zero/fire3

var zero: bool = false

func set_direction(new_direction):
	facing_direction = new_direction
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	animatedSprite.scale.x = new_direction
	if not animatedSprite_zero:
		animatedSprite_zero = get_node("animatedSprite_zero")
	animatedSprite_zero.scale.x = new_direction
	if zero:
		animatedSprite.hide()
		animatedSprite_zero.show()
	else:
		animatedSprite.show()
		animatedSprite_zero.hide()

func _Update(delta: float) -> void :
	if zero:
		animatedSprite.hide()
		animatedSprite_zero.show()
	else:
		animatedSprite.show()
		animatedSprite_zero.hide()
	if not exploded and is_on_wall():
		explode()

func explode() -> void :
	fire_1.emitting = false
	fire_2.emitting = false
	fire_3.emitting = false
	exploded = true
	animatedSprite.play("explode")
	if zero:
		fire_zero_1.emitting = false
		fire_zero_2.emitting = false
		fire_zero_3.emitting = false
		animatedSprite_zero.play("explode")
	disable_damage()
	Tools.timer(1, "destroy", self)
	vanish.play_rp()
	create_mini_projectile()

func create_mini_projectile():
	var projectile = mini_projectile.instance()
	get_tree().current_scene.add_child(projectile, true)
	projectile.set_global_position(global_position)
	projectile.set_creator(creator)
	projectile.initialize(facing_direction)
	projectile.set_vertical_speed( - 150)
	if zero:
		projectile.zero = zero
		projectile.set_vertical_speed( - 250)

func _OnHit(_target_remaining_HP) -> void :
	pass

