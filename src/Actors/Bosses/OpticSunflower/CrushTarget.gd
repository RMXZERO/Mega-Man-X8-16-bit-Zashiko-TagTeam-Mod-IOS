extends Node2D

var pursuit_speed := 120.0
var h_speed := 0.0
var v_speed := 0.0
onready var animated_sprite: AnimatedSprite = $animatedSprite

signal fire(pos)

func _ready() -> void:
	Tools.tween(animated_sprite,"speed_scale",2,2.0)
	Tools.timer(2.0,"fire",self)
	max_beam_offset = 32
	beam_1_offset = 0
	beam_2_offset = 1.57
	beam_3_offset = 3.14

func fire() -> void:
	emit_signal("fire",global_position)
	queue_free()

func _physics_process(delta: float) -> void:
	global_position.x += h_speed * delta
	global_position.y += v_speed * delta
	crash_beam_rotation(delta)
	if is_distant_enough():
		var target_angle = get_angle_to(GameManager.get_player_position())
		var normalized_angle = Vector2(cos(target_angle),sin(target_angle))
		h_speed = (normalized_angle.x * pursuit_speed)
		v_speed = (normalized_angle.y * pursuit_speed)
	else:
		h_speed = (0)
		v_speed = (0)
		
func is_distant_enough() -> bool:
	var distance := global_position.distance_to(GameManager.get_player_position())
	return distance > 8.0

var max_beam_offset: float = 32
var beam_1_offset: float = 0
var beam_2_offset: float = 1.57
var beam_3_offset: float = 3.14

onready var beam_1 = animated_sprite.get_node("crash_beam")
onready var beam_2 = animated_sprite.get_node("crash_beam2")
onready var beam_3 = animated_sprite.get_node("crash_beam3")

func crash_beam_rotation(delta: float) -> void :
	if max_beam_offset > 0:
		max_beam_offset -= delta * 16
		beam_1_offset -= delta * 15
		beam_2_offset -= delta * 15
		beam_3_offset -= delta * 15
		beam_1.visible = true
		beam_2.visible = true
		beam_3.visible = true
	beam_1.position.y = GameManager.camera.get_camera_screen_center().y - position.y
	beam_2.position.y = GameManager.camera.get_camera_screen_center().y - position.y
	beam_3.position.y = GameManager.camera.get_camera_screen_center().y - position.y
	beam_1.position.x = 0 + max_beam_offset * sin(beam_1_offset)
	beam_2.position.x = 0 + max_beam_offset * sin(beam_2_offset)
	beam_3.position.x = 0 + max_beam_offset * sin(beam_3_offset)
