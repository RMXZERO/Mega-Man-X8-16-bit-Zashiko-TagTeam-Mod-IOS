extends Node

onready var main: = $"../.."

const subtle_motion: Array = [Vector2(1, 1), Vector2( - 1, - 1), Vector2(1, - 1), Vector2( - 1, 1), Vector2(0, 0)]

export var active: bool = false
var frequency: float = 0.075
var duration: float = 0.75
var extra_y_position: float = 0
var extra_scale: float = 1
var extra_z_index: float = 1
export var ignored_colors: Array = [
	Color(0, 0, 0), 
	Color(0, 0, 0), 
	Color(0, 0, 0), 
	Color(0, 0, 0), 
	Color(0, 0, 0), 
	Color(0, 0, 0), 
	Color(0, 0, 0), 
	Color(0, 0, 0)
]

export  var motion_amount: float = 0.0

onready var character = get_parent().get_parent().get_parent()
onready var original: AnimatedSprite = character.get_node("animatedSprite")

var initial_color: Color = Color("#00000000")
var final_color: Color = Color("#00000000")
var upgraded: bool = false
var current_motion: = 0
var _rotator_script: Script = preload("res://System/misc/rotatordelete.gd")
var emit: bool = false

func _ready() -> void :
	frequency = 0.01
	duration = 0.01
	extra_y_position = -4
	extra_scale = 1.5
	extra_z_index = 0
	initial_color = main.initial_color
	final_color = main.initial_color
	call_deferred("set_shader_colors")
	Event.listen("beamin", self, "can_emit")
	Event.listen("x_appear", self, "can_emit")
	Event.listen("gameplay_start", self, "can_emit")
	Event.listen("character_switch", self, "switch_in_active")
	Event.listen("character_switch_end", self, "switch_out_active")
	Event.listen("customzerocolor", self, "set_shader_colors")
	Event.listen("ridearmor_activate", self, "false_emit")
	Event.listen("ridearmor_deactivate", self, "can_emit")
	active = false
	if active:
		afterimage_emit()

func zero_beta() -> void :
	if not main.player_zero_beta:
		return
	if not character.is_current_player:
		return
	if CharacterManager.awakened_zero_armor and CharacterManager.extra_saber_color:
		if not upgraded:
			upgraded = true
			if not active:
				active = true
				upgraded = true
				set_shader_colors()
				afterimage_emit()

func can_emit() -> void :
	if character.is_current_player:
		emit = true
	zero_beta()

func switch_in_active() -> void :
	if character.is_current_player:
		active = true
	can_emit()
	if upgraded:
		if character.is_current_player:
			set_shader_colors()
			afterimage_emit()
	zero_beta()

func switch_out_active() -> void :
	if not character.is_current_player:
		active = false
	can_emit()

func false_emit() -> void :
	emit = false

func set_shader_colors():
	var material = original.get_material()
	if main.zero_material_color:
		if material is ShaderMaterial:
			initial_color = material.get_shader_param("R_AuraColor")
			final_color = material.get_shader_param("R_AuraColor")
		if CharacterManager.awakened_zero_armor and CharacterManager.extra_saber_color and main.player_zero_beta:
			initial_color = main.initial_color
			final_color = main.initial_color

func _process(_delta):
	pass

func activate():
	if not active:
		active = true
		upgraded = true
		afterimage_emit()

func deactivate():
	active = false
	upgraded = false
	if main.player_zero_beta:
		if CharacterManager.awakened_zero_armor and CharacterManager.extra_saber_color:
			active = true
			upgraded = true
			afterimage_emit()

func set_afterimage_shader(_afterimage) -> void :
	var material = ShaderMaterial.new()
	material.shader = load("res://Zero_mod/Player/DashShader.shader")
	material.set_shader_param("display_color", initial_color)
	material.set_shader_param("ignored_color_1", ignored_colors[0])
	material.set_shader_param("ignored_color_2", ignored_colors[1])
	material.set_shader_param("ignored_color_3", ignored_colors[2])
	material.set_shader_param("ignored_color_4", ignored_colors[3])
	material.set_shader_param("ignored_color_5", ignored_colors[4])
	material.set_shader_param("ignored_color_6", ignored_colors[5])
	material.set_shader_param("ignored_color_7", ignored_colors[6])
	material.set_shader_param("ignored_color_8", ignored_colors[7])
	_afterimage.material = material

func afterimage_emit() -> void :
	if active:
		var afterimage: = AnimatedSprite.new()
		add_child(afterimage)
		equate_settings(afterimage)
		set_afterimage_shader(afterimage)
		fade_and_delete(afterimage)
		var rotator = Node.new()
		rotator.set_name("rotator")
		rotator.set_script(_rotator_script)
		afterimage.add_child(rotator)
		Tools.timer(frequency, "afterimage_emit", self)
			

func fade_and_delete(afterimage: AnimatedSprite) -> void :
	if not emit or original.animation == "empty" or original.animation == "messiah_flash":
		afterimage.self_modulate = Color(1, 1, 1, 0)
	else:
		afterimage.modulate = initial_color
	var tween: = afterimage.create_tween().set_parallel(true)
	tween.tween_property(afterimage, "modulate", final_color, duration)
	tween.tween_property(afterimage, "position", afterimage.position + get_motion(), duration)
	tween.set_parallel(false)
	#Tools.timer(duration, "queue_free", afterimage)
	tween.tween_callback(afterimage, "queue_free")

func equate_settings(afterimage: AnimatedSprite) -> void :
	afterimage.scale = original.scale * rand_range( 1, extra_scale)
	afterimage.frames = original.frames
	afterimage.animation = original.animation
	afterimage.frame = original.frame
	afterimage.playing = false
	afterimage.centered = original.centered
	afterimage.offset = original.offset
	afterimage.flip_h = original.flip_h
	afterimage.flip_v = original.flip_v
	afterimage.z_index = 1
	afterimage.global_position = original.global_position + Vector2(0, extra_y_position)
	afterimage.rotation_degrees = original.rotation_degrees
	afterimage.z_index = original.z_index - extra_z_index
	afterimage.visible = character.visible

func get_motion() -> Vector2:
	current_motion += 1
	if current_motion > subtle_motion.size() - 1:
		current_motion = 0
	return subtle_motion[current_motion] * motion_amount
