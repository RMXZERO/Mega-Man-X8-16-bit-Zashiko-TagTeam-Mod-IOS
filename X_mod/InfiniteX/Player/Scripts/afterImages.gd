extends Node

const subtle_motion := [Vector2(1,1),Vector2(-1,-1),Vector2(1,-1),Vector2(-1,1),Vector2(0,0)]
var current_motion := 0
export var active := false
export var frequency := 0.1
export var duration := 0.5
export var initial_color: Color = Color("#796f6be9")
export var final_color: Color = Color("#00422c93")
export var motion_amount := 0.0
onready var original: AnimatedSprite = $".."
onready var character = get_parent().get_parent()
var emit: bool = false

var false_states: Array = [
	"Intro", 
	"Death", 
	"WeaponStasis", 
	"Ride",
]

func _ready() -> void :
	Event.listen("beamin", self, "can_emit")
	Event.listen("x_appear", self, "can_emit")
	Event.listen("gameplay_start", self, "can_emit")
	Event.listen("character_switch", self, "can_emit")
	Event.listen("character_switch_end", self, "can_emit")
	Event.listen("ridearmor_activate", self, "false_emit")
	Event.listen("ridearmor_deactivate", self, "can_emit")

func can_emit() -> void :
	if character.is_current_player:
		emit = true

func false_emit() -> void :
	emit = false

func _process(_delta):
	if not emit:
		deactivate()
		return
	for state in false_states:
		if character.is_executing(state):
			deactivate()
			return
		if character.is_executing("WeaponStasis"):
			deactivate()
			return
		if character.is_executing("Ride"):
			deactivate()
			return
		if character.is_executing("Intro"):
			deactivate()
			return
		if character.is_executing("Death"):
			deactivate()
			return
		activate()

func set_shader_colors():
	pass

func activate():
	if not active:
		active = true
		afterimage_emit()

func deactivate():
	active = false

func afterimage_emit():
	if frequency == 0 or duration == 0:
		return
	if active:
		var afterimage := AnimatedSprite.new()
		add_child(afterimage)
		equate_settings(afterimage)
		fade_and_delete(afterimage)
		Tools.timer(frequency,"afterimage_emit",self)
		
func fade_and_delete(afterimage :AnimatedSprite) -> void:
	if not emit:
		afterimage.self_modulate = Color(1, 1, 1, 0)
	else:
		afterimage.modulate = initial_color
	var tween := afterimage.create_tween().set_parallel(true)
	tween.tween_property(afterimage,"modulate",final_color,duration)
	tween.tween_property(afterimage,"position",afterimage.position + get_motion(),duration)
	tween.set_parallel(false)
	tween.tween_callback(afterimage,"queue_free")

func equate_settings(afterimage :AnimatedSprite) -> void:
	afterimage.scale = original.scale
	afterimage.frames = original.frames
	afterimage.animation = original.animation
	afterimage.frame = original.frame
	afterimage.playing = false
	afterimage.centered = original.centered
	afterimage.offset = original.offset
	afterimage.flip_h = original.flip_h
	afterimage.flip_v = original.flip_v
	afterimage.z_index = 1
	afterimage.global_position = original.global_position
	afterimage.rotation_degrees = original.rotation_degrees
	afterimage.visible = character.visible
	
func get_motion() -> Vector2:
	current_motion += 1
	if current_motion > subtle_motion.size() - 1:
		current_motion = 0
	return subtle_motion[current_motion] * motion_amount
